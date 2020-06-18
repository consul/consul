class AddTenantToDelayedJob < ActiveRecord::Migration[4.2]
  def change
    add_column :delayed_jobs, :tenant, :string
  end
end
