class AddUnsubscribeHashToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :unsubscribe_hash, :string
  end
end
