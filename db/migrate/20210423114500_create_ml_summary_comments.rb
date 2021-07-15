class CreateMlSummaryComments < ActiveRecord::Migration[5.2]
  def change
    create_table :ml_summary_comments do |t|
      t.integer :commentable_id
      t.string :commentable_type
      t.text :body

      t.timestamps
    end
  end
end
