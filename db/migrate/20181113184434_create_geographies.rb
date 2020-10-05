class CreateGeographies < ActiveRecord::Migration[5.0]
  def change
    create_table :geographies do |t|
      t.string :name
      t.text :geojson
      t.string :color

      t.timestamps null: false
    end
  end
end
