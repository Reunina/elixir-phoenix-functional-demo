defmodule TurboOctoPancakes.Repo.Migrations.AddUsersSearchIndex do
  use Ecto.Migration

  def up do
    execute """
    CREATE INDEX users_name_trgm_idx ON users
    USING gin ((first_name || ' ' || last_name) gin_trgm_ops)
    """
  end

  def down do
    execute "DROP INDEX IF EXISTS users_name_trgm_idx"
  end
end
