class AddOptionsToLegislationProcess < ActiveRecord::Migration
  def change
    add_column :legislation_processes, :title_label, :string
    add_column :legislation_processes, :summary_label, :string
    add_column :legislation_processes, :description_enabled, :boolean, default: true
    add_column :legislation_processes, :description_label, :string
    add_column :legislation_processes, :video_url_enabled, :boolean, default: true
    add_column :legislation_processes, :video_url_label, :string
    add_column :legislation_processes, :image_enabled, :boolean, default: true
    add_column :legislation_processes, :image_label, :string
    add_column :legislation_processes, :documents_enabled, :boolean, default: true
    add_column :legislation_processes, :documents_label, :string
    add_column :legislation_processes, :geozone_enabled, :boolean, default: true
    add_column :legislation_processes, :geozone_label, :string
    add_column :legislation_processes, :tags_enabled, :boolean, default: true
    add_column :legislation_processes, :tags_label, :string
  end
end
