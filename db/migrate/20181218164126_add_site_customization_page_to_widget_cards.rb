class AddSiteCustomizationPageToWidgetCards < ActiveRecord::Migration
  def change
    add_reference :widget_cards, :site_customization_page, index: true, default: 0
  end
end
