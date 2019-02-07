class AddGeographyToHeadings < ActiveRecord::Migration
  def change
    add_reference :budget_headings, :geography, index: true, foreign_key: true
  end
end
