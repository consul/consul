require "rails_helper"

describe "Admin proposal notifications", :admin do
  scenario "List shows all relevant info" do
    proposal_notification = create(:proposal_notification, :hidden)
    visit admin_hidden_proposal_notifications_path

    expect(page).to have_content(proposal_notification.title)
    expect(page).to have_content(proposal_notification.body)
  end

  scenario "Restore" do
    proposal_notification = create(:proposal_notification, :hidden, created_at: Date.current - 5.days)
    visit admin_hidden_proposal_notifications_path

    accept_confirm("Restore: Are you sure?") { click_link "Restore" }

    expect(page).not_to have_content(proposal_notification.title)

    logout
    login_as(proposal_notification.author)
    visit proposal_notification_path(proposal_notification)

    expect(page).to have_content(proposal_notification.title)
  end

  scenario "Confirm hide" do
    proposal_notification = create(:proposal_notification, :hidden, created_at: Date.current - 5.days)
    visit admin_hidden_proposal_notifications_path

    click_link "Confirm moderation"

    expect(page).not_to have_content(proposal_notification.title)
    click_link("Confirmed")
    expect(page).to have_content(proposal_notification.title)
  end

  scenario "Current filter is properly highlighted" do
    visit admin_hidden_proposal_notifications_path
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposal_notifications_path(filter: "Pending")
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposal_notifications_path(filter: "all")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposal_notifications_path(filter: "with_confirmed_hide")
    expect(page).to have_link("All")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("Confirmed")
  end

  scenario "Filtering proposals" do
    create(:proposal_notification, :hidden, title: "Unconfirmed notification")
    create(:proposal_notification, :hidden, :with_confirmed_hide, title: "Confirmed notification")

    visit admin_hidden_proposal_notifications_path(filter: "pending")
    expect(page).to have_content("Unconfirmed notification")
    expect(page).not_to have_content("Confirmed notification")

    visit admin_hidden_proposal_notifications_path(filter: "all")
    expect(page).to have_content("Unconfirmed notification")
    expect(page).to have_content("Confirmed notification")

    visit admin_hidden_proposal_notifications_path(filter: "with_confirmed_hide")
    expect(page).not_to have_content("Unconfirmed notification")
    expect(page).to have_content("Confirmed notification")
  end

  scenario "Action links remember the pagination setting and the filter" do
    allow(ProposalNotification).to receive(:default_per_page).and_return(2)
    4.times { create(:proposal_notification, :hidden, :with_confirmed_hide) }

    visit admin_hidden_proposal_notifications_path(filter: "with_confirmed_hide", page: 2)

    accept_confirm("Restore: Are you sure?") { click_link "Restore", match: :first, exact: true }

    expect(page).to have_current_path(/filter=with_confirmed_hide/)
    expect(page).to have_current_path(/page=2/)
  end
end
