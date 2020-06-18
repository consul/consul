class AddCensusToTenants < ActiveRecord::Migration[4.2]
  def change
    add_column :tenants, :endpoint_census, :string
    add_column :tenants, :institution_code_census, :string
    add_column :tenants, :portal_name_census, :string
    add_column :tenants, :user_code_census, :string
  end
end
