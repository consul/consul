require "rails_helper"

describe "Admin hidden users", :admin do
  scenario "Show user activity" do
    user = create(:user, :hidden)

    debate1 = create(:debate, :hidden, author: user)
    debate2 = create(:debate, author: user)
    comment1 = create(:comment, :hidden, user: user, commentable: debate2, body: "You have the manners of a beggar")
    comment2 = create(:comment, user: user, commentable: debate2, body: "Not Spam")

    visit admin_hidden_user_path(user)

    expect(page).to have_content(debate1.title)
    expect(page).to have_content(debate2.title)
    expect(page).to have_content(comment1.body)
    expect(page).to have_content(comment2.body)
  end

  scenario "Restore" do
    user = create(:user, :hidden)
    visit admin_hidden_users_path

    accept_confirm("Restore: Are you sure?") { click_link "Restore" }

    expect(page).not_to have_content(user.username)

    visit user_path(user)

    expect(page).to have_content(user.username)
  end

  scenario "Confirm hide" do
    user = create(:user, :hidden)
    visit admin_hidden_users_path

    click_link "Confirm moderation"

    expect(page).not_to have_content(user.username)
    click_link("Confirmed")
    expect(page).to have_content(user.username)
  end

  scenario "Current filter is properly highlighted" do
    visit admin_hidden_users_path
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_users_path(filter: "Pending")
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_users_path(filter: "all")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_users_path(filter: "with_confirmed_hide")
    expect(page).to have_link("All")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("Confirmed")
  end

  scenario "Filtering users" do
    create(:user, :hidden, username: "Unconfirmed")
    create(:user, :hidden, :with_confirmed_hide, username: "Confirmed user")

    visit admin_hidden_users_path(filter: "all")
    expect(page).to have_content("Unconfirmed")
    expect(page).to have_content("Confirmed user")

    visit admin_hidden_users_path(filter: "with_confirmed_hide")
    expect(page).not_to have_content("Unconfirmed")
    expect(page).to have_content("Confirmed user")
  end

  scenario "Action links remember the pagination setting and the filter" do
    allow(User).to receive(:default_per_page).and_return(2)
    4.times { create(:user, :hidden, :with_confirmed_hide) }

    visit admin_hidden_users_path(filter: "with_confirmed_hide", page: 2)

    accept_confirm("Restore: Are you sure?") { click_link "Restore", match: :first, exact: true }

    expect(page).to have_current_path(/filter=with_confirmed_hide/)
    expect(page).to have_current_path(/page=2/)
  end
end
