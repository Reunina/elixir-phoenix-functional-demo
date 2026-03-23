defmodule ElixirPhoenixFunctionalDemo.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def up do
    create table(:products, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      add :currency_code,
          references(:currencies, column: :code, type: :string),
          null: false

      add :stock, :integer, null: false
      add :price, :integer, null: false
      add :label, :string, null: false
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:products, [:user_id])
    create index(:products, [:currency_code])

    create unique_index(:products, [:user_id],
             where: "end_date IS NULL",
             name: :unique_active_product_per_user
           )

    # Automatically set inserted_at/updated_at in UTC (server-side)
    execute """
    CREATE OR REPLACE FUNCTION set_timestamps_products()
    RETURNS TRIGGER AS $$
    BEGIN
      IF TG_OP = 'INSERT' THEN
        NEW.inserted_at := (now() AT TIME ZONE 'UTC');
      END IF;
      NEW.updated_at := (now() AT TIME ZONE 'UTC');
      RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;
    """

    execute """
    CREATE TRIGGER products_set_timestamps_insert
    BEFORE INSERT ON products
    FOR EACH ROW
    EXECUTE PROCEDURE set_timestamps_products();
    """

    execute """
    CREATE TRIGGER products_set_timestamps_update
    BEFORE UPDATE ON products
    FOR EACH ROW
    EXECUTE PROCEDURE set_timestamps_products();
    """
  end

  def down do
    execute """
    DROP TRIGGER IF EXISTS products_set_timestamps_update ON products;
    """

    execute """
    DROP TRIGGER IF EXISTS products_set_timestamps_insert ON products;
    """

    execute """
    DROP FUNCTION IF EXISTS set_timestamps_products();
    """

    drop_if_exists index(:products, [:user_id])
    drop_if_exists index(:products, [:currency_code])
    drop_if_exists index(:products, [:user_id], name: :unique_active_product_per_user)

    drop table(:products)
  end
end
