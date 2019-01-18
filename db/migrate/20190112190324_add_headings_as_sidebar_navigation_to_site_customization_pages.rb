class AddHeadingsAsSidebarNavigationToSiteCustomizationPages < ActiveRecord::Migration
  def change
    add_column :site_customization_pages, :headings_as_sidebar_navigation, :boolean, default: false
  end
end
