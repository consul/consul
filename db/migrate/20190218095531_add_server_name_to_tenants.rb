class AddServerNameToTenants < ActiveRecord::Migration[4.2]
  def change
    add_column :tenants, :server_name, :string
  end
end
