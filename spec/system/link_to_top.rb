require "rails_helper"

describe "Link to top" do
  scenario "Display if feature is enabled", :js do
    window_height = page.evaluate_script("window.innerHeight;")
    scroll = (window_height * 20 / 100) + 1

    visit root_path
    expect(page).to have_link("Go back to the top of the page", visible: :hidden)

    execute_script "window.scrollTo(0, #{scroll})"
    expect(page.evaluate_script("window.scrollY;")).not_to eq(0)
    expect(page).to have_link("Go back to the top of the page", visible: :visible)

    click_link "Go back to the top of the page"
    expect(page.evaluate_script("window.scrollY;")).to eq(0)

    login_as(create(:administrator).user)

    visit admin_root_path
    expect(page).to have_link("Go back to the top of the page", visible: :hidden)

    execute_script "window.scrollTo(0, #{scroll})"
    expect(page).to have_link("Go back to the top of the page", visible: :visible)
    expect(page.evaluate_script("window.scrollY;")).not_to eq(0)

    click_link "Go back to the top of the page"
    expect(page.evaluate_script("window.scrollY;")).to eq(0)
  end

  scenario "Do not display if feature is disabled" do
    Setting["feature.link_to_top"] = false

    visit root_path

    within("#body") do
      expect(page).not_to have_link "Go back to the top of the page"
    end

    login_as(create(:administrator).user)
    visit admin_root_path

    within("#body") do
      expect(page).not_to have_link "Go back to the top of the page"
    end
  end
end
