class CreateSharedExtensionsSchema < ActiveRecord::Migration[5.1]
  def up
    schema = "shared_extensions"

    execute "CREATE SCHEMA IF NOT EXISTS #{schema};"

    %w[unaccent pg_trgm].each do |extension|
      execute "DROP EXTENSION IF EXISTS #{extension};"
      execute "CREATE EXTENSION #{extension} SCHEMA #{schema};"
    end

    execute "GRANT usage ON SCHEMA #{schema} TO public;"
  end

  def down
    execute "DROP SCHEMA shared_extensions;"
  end
end
