defmodule TurboOctoPancakes.Repo.Migrations.CreateCurrencies do
  use Ecto.Migration

  def up do
    create table(:currencies, primary_key: false) do
      add :code, :string, size: 3, primary_key: true
      add :decimal, :integer, default: 2

      add :inserted_at, :utc_datetime,
        null: false,
        default: fragment("(now() AT TIME ZONE 'UTC')")

      add :updated_at, :utc_datetime, null: false, default: fragment("(now() AT TIME ZONE 'UTC')")
    end

    # Automatically set inserted_at/updated_at in UTC (server-only, ignores client values)
    execute """
    CREATE OR REPLACE FUNCTION set_timestamps_currencies()
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
    CREATE TRIGGER currencies_set_timestamps_insert
    BEFORE INSERT ON currencies
    FOR EACH ROW
    EXECUTE PROCEDURE set_timestamps_currencies();
    """

    execute """
    CREATE TRIGGER currencies_set_timestamps_update
    BEFORE UPDATE ON currencies
    FOR EACH ROW
    EXECUTE PROCEDURE set_timestamps_currencies();
    """
  end

  def down do
    execute "DROP TRIGGER IF EXISTS currencies_set_timestamps_update ON currencies"
    execute "DROP TRIGGER IF EXISTS currencies_set_timestamps_insert ON currencies"
    execute "DROP FUNCTION IF EXISTS set_timestamps_currencies()"

    drop table(:currencies)
  end
end
