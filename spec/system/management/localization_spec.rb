require "rails_helper"

describe "Localization" do
  scenario "Wrong locale" do
    login_as_manager
    visit management_root_path(locale: :es)
    visit management_root_path(locale: :klingon)

    expect(page).to have_text("Gestión")
  end

  scenario "Changing the locale" do
    login_as_manager
    select_language "Español"

    expect(page).not_to have_content "Language:"
    expect(page).to have_content "Idioma:"
    expect(page).to have_link "Español"
    expect(page).to have_content "Gestión"
  end
end
