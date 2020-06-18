class AddOmniauthToTenants < ActiveRecord::Migration[5.1]
  def change
    change_table :tenants do |t|
      t.string :twitter_key
      t.string :twitter_secret
      t.string :facebook_key
      t.string :facebook_secret
    end
  end
end
