class AddTsvVector < ActiveRecord::Migration
  def change
    add_column :comments, :tsv, :tsvector
    add_index :comments, :tsv, using: "gin"

    add_column :proposal_notifications, :tsv, :tsvector
    add_index :proposal_notifications, :tsv, using: "gin"
  end
end
