defmodule ElixirPhoenixFunctionalDemo.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def up do
    create table(:users, primary_key: false) do
      add :id, :uuid, primary_key: true, default: fragment("gen_random_uuid()")
      add :first_name, :string, null: false
      add :last_name, :string, null: false

      #  inserted_at / updated_at auto-managed, stored in UTC (timestamptz)
      timestamps(type: :utc_datetime_usec)
    end

    # Automatically set inserted_at/updated_at in UTC (server-only, ignores client values)
    execute """
    CREATE OR REPLACE FUNCTION set_timestamps_users()
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
    CREATE TRIGGER users_set_timestamps_insert
    BEFORE INSERT ON users
    FOR EACH ROW
    EXECUTE PROCEDURE set_timestamps_users();
    """

    execute """
    CREATE TRIGGER users_set_timestamps_update
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE PROCEDURE set_timestamps_users();
    """
  end

  def down do
    execute "DROP TRIGGER IF EXISTS users_set_timestamps_update ON users"
    execute "DROP TRIGGER IF EXISTS users_set_timestamps_insert ON users"
    execute "DROP FUNCTION IF EXISTS set_timestamps_users()"

    drop table(:users)
  end
end
