require "rails_helper"

describe "Admin hidden budget investments", :admin do
  let(:budget)  { create(:budget) }
  let(:heading) { create(:budget_heading, budget: budget, price: 666666) }

  scenario "List shows all relevant info" do
    investment = create(:budget_investment, :hidden, heading: heading)

    visit admin_hidden_budget_investments_path

    expect(page).to have_content(investment.title)
    expect(page).to have_content(investment.description)
  end

  scenario "Restore" do
    investment = create(:budget_investment, :hidden, heading: heading)

    visit admin_hidden_budget_investments_path

    accept_confirm("Restore: Are you sure?") { click_link "Restore" }

    expect(page).not_to have_content(investment.title)

    visit budget_investment_path(investment.budget, investment)

    expect(page).to have_content(investment.title)
  end

  scenario "Confirm hide" do
    investment = create(:budget_investment, :hidden, heading: heading)
    visit admin_hidden_budget_investments_path

    click_link "Pending"

    expect(page).not_to have_link "Pending"
    expect(page).to have_content(investment.title)

    click_link "Confirm moderation"

    expect(page).not_to have_content(investment.title)

    click_link("Confirmed")
    expect(page).to have_content(investment.title)
  end

  scenario "Current filter is properly highlighted" do
    visit admin_hidden_budget_investments_path
    expect(page).not_to have_link("All")
    expect(page).to have_link("Pending")
    expect(page).to have_link("Confirmed")

    visit admin_hidden_budget_investments_path(filter: "without_confirmed_hide")
    expect(page).to have_link("All")
    expect(page).to have_link("Confirmed")
    expect(page).not_to have_link("Pending")

    visit admin_hidden_budget_investments_path(filter: "with_confirmed_hide")
    expect(page).to have_link("All")
    expect(page).to have_link("Pending")
    expect(page).not_to have_link("Confirmed")
  end

  scenario "Filtering investments" do
    create(:budget_investment, :hidden, heading: heading, title: "Unconfirmed investment")
    create(:budget_investment, :hidden, :with_confirmed_hide, heading: heading, title: "Confirmed investment")

    visit admin_hidden_budget_investments_path(filter: "without_confirmed_hide")
    expect(page).to have_content("Unconfirmed investment")
    expect(page).not_to have_content("Confirmed investment")

    visit admin_hidden_budget_investments_path(filter: "all")
    expect(page).to have_content("Unconfirmed investment")
    expect(page).to have_content("Confirmed investment")

    visit admin_hidden_budget_investments_path(filter: "with_confirmed_hide")
    expect(page).not_to have_content("Unconfirmed investment")
    expect(page).to have_content("Confirmed investment")
  end

  scenario "Action links remember the pagination setting and the filter" do
    allow(Budget::Investment).to receive(:default_per_page).and_return(2)
    4.times { create(:budget_investment, :hidden, :with_confirmed_hide, heading: heading) }

    visit admin_hidden_budget_investments_path(filter: "with_confirmed_hide", page: 2)

    accept_confirm("Restore: Are you sure?") { click_link "Restore", match: :first, exact: true }

    expect(page).to have_current_path(/filter=with_confirmed_hide/)
    expect(page).to have_current_path(/page=2/)
  end
end
