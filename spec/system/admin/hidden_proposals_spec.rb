require "rails_helper"

describe "Admin hidden proposals", :admin do
  scenario "List shows all relevant info" do
    proposal = create(:proposal, :hidden)
    visit admin_hidden_proposals_path

    expect(page).to have_content(proposal.title)
    expect(page).to have_content(proposal.summary)
    expect(page).to have_content(proposal.description)

    find("td", text: proposal.summary).hover

    expect(page).to have_content(proposal.video_url)
  end

  scenario "Restore" do
    proposal = create(:proposal, :hidden)
    visit admin_hidden_proposals_path

    accept_confirm("Restore: Are you sure?") { click_link "Restore" }

    expect(page).not_to have_content(proposal.title)

    visit proposal_path(proposal)

    expect(page).to have_content proposal.title
  end

  scenario "Confirm hide" do
    proposal = create(:proposal, :hidden)
    visit admin_hidden_proposals_path

    click_link "Confirm moderation"

    expect(page).not_to have_content(proposal.title)
    click_link("Confirmed")
    expect(page).to have_content(proposal.title)
  end

  scenario "Current filter is properly highlighted" do
    visit admin_hidden_proposals_path
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposals_path(filter: "Pending")
    expect(page).not_to have_link("Pending")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposals_path(filter: "all")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("All")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_proposals_path(filter: "with_confirmed_hide")
    expect(page).to have_link("All")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("Confirmed")
  end

  scenario "Filtering proposals" do
    create(:proposal, :hidden, title: "Unconfirmed proposal")
    create(:proposal, :hidden, :with_confirmed_hide, title: "Confirmed proposal")

    visit admin_hidden_proposals_path(filter: "pending")
    expect(page).to have_content("Unconfirmed proposal")
    expect(page).not_to have_content("Confirmed proposal")

    visit admin_hidden_proposals_path(filter: "all")
    expect(page).to have_content("Unconfirmed proposal")
    expect(page).to have_content("Confirmed proposal")

    visit admin_hidden_proposals_path(filter: "with_confirmed_hide")
    expect(page).not_to have_content("Unconfirmed proposal")
    expect(page).to have_content("Confirmed proposal")
  end

  scenario "Action links remember the pagination setting and the filter" do
    allow(Proposal).to receive(:default_per_page).and_return(2)
    4.times { create(:proposal, :hidden, :with_confirmed_hide) }

    visit admin_hidden_proposals_path(filter: "with_confirmed_hide", page: 2)

    accept_confirm("Restore: Are you sure?") { click_link "Restore", match: :first, exact: true }

    expect(page).to have_current_path(/filter=with_confirmed_hide/)
    expect(page).to have_current_path(/page=2/)
  end
end
