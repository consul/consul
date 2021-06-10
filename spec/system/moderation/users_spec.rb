require "rails_helper"

describe "Moderate users" do
  scenario "Hide" do
    citizen = create(:user)
    moderator = create(:moderator)

    debate1 = create(:debate, author: citizen)
    debate2 = create(:debate, author: citizen)
    debate3 = create(:debate)
    comment3 = create(:comment, user: citizen, commentable: debate3, body: "SPAMMER")

    login_as(moderator.user)
    visit debates_path

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).to have_content(comment3.body)

    visit debate_path(debate1)

    within("#debate_#{debate1.id}") do
      accept_confirm("Hide author: Are you sure?") { click_link "Hide author" }
    end

    expect(page).to have_current_path(debates_path)
    expect(page).not_to have_content(debate1.title)
    expect(page).not_to have_content(debate2.title)
    expect(page).to have_content(debate3.title)

    visit debate_path(debate3)

    expect(page).not_to have_content(comment3.body)

    click_link("Sign out")

    visit root_path

    click_link "Sign in"
    fill_in "user_login",    with: citizen.email
    fill_in "user_password", with: citizen.password
    click_button "Enter"

    expect(page).to have_content "Invalid Email or username or password"
    expect(page).to have_current_path(new_user_session_path)
  end

  scenario "Search and ban users" do
    citizen = create(:user, username: "Wanda Maximoff")
    moderator = create(:moderator)

    login_as(moderator.user)

    visit moderation_users_path

    expect(page).not_to have_content citizen.name
    fill_in "search", with: "Wanda"
    click_button "Search"

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).not_to have_content "Blocked"
      click_link "Block"
    end

    within("#moderation_users") do
      expect(page).to have_content citizen.name
      expect(page).to have_content "Blocked"
    end
  end
end
