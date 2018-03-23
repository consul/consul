require 'rails_helper'

feature "Custom content blocks" do
  xscenario "top links" do
    create(:site_customization_content_block, name: "top_links", locale: "en", body: "content for top links")
    create(:site_customization_content_block, name: "top_links", locale: "es", body: "contenido para top links")

    visit "/?locale=en"

    expect(page).to have_content("content for top links")
    expect(page).not_to have_content("contenido para top links")

    visit "/?locale=es"

    expect(page).to have_content("contenido para top links")
    expect(page).not_to have_content("content for top links")
  end

  xscenario "footer" do
    create(:site_customization_content_block, name: "footer", locale: "en", body: "content for footer")
    create(:site_customization_content_block, name: "footer", locale: "es", body: "contenido para footer")

    visit "/?locale=en"

    expect(page).to have_content("content for footer")
    expect(page).not_to have_content("contenido para footer")

    visit "/?locale=es"

    expect(page).to have_content("contenido para footer")
    expect(page).not_to have_content("content for footer")
  end
end
