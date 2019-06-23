require "rails_helper"

describe "Budgets" do

  let(:budget)             { create(:budget) }
  let(:level_two_user)     { create(:user, :level_two) }
  let(:allowed_phase_list) { ["balloting", "reviewing_ballots", "finished"] }

  context "Load" do

    before { budget.update(slug: "budget_slug") }

    scenario "finds budget by slug" do
      visit budget_path("budget_slug")

      expect(page).to have_content budget.name
    end

    scenario "raises an error if budget slug is not found" do
      expect do
        visit budget_path("wrong_budget")
      end.to raise_error ActiveRecord::RecordNotFound
    end

    scenario "raises an error if budget id is not found" do
      expect do
        visit budget_path(0)
      end.to raise_error ActiveRecord::RecordNotFound
    end

  end

  context "Index" do

    scenario "Show normal index with links" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)
      heading1 = create(:budget_heading, group: group1)
      heading2 = create(:budget_heading, group: group2)

      budget.update_attributes(phase: "informing")

      visit budgets_path

      within("#budget_heading") do
        expect(page).to have_content(budget.name)
        expect(page).to have_content(budget.description)
        expect(page).to have_content("Actual phase")
        expect(page).to have_content("Information")
        expect(page).to have_link("Help with participatory budgets")
        expect(page).to have_link("See all phases")
      end

      budget.update_attributes(phase: "publishing_prices")
      visit budgets_path

      within("#budget_heading") do
        expect(page).to have_content("Publishing projects prices")
      end

      within("#budget_info") do
        expect(page).to have_content(group1.name)
        expect(page).to have_content(group2.name)
        expect(page).to have_content(heading1.name)
        expect(page).to have_content(budget.formatted_heading_price(heading1))
        expect(page).to have_content(heading2.name)
        expect(page).to have_content(budget.formatted_heading_price(heading2))
      end

      expect(page).not_to have_content("#finished_budgets")
    end

    scenario "Show finished budgets list" do
      finished_budget_1 = create(:budget, :finished)
      finished_budget_2 = create(:budget, :finished)
      drafting_budget = create(:budget, :drafting)
      visit budgets_path

      within("#finished_budgets") do
        expect(page).to     have_content(finished_budget_1.name)
        expect(page).to     have_content(finished_budget_2.name)
        expect(page).not_to have_content(budget.name)
        expect(page).not_to have_content(drafting_budget.name)
      end
    end

    scenario "Show headings ordered by name" do
      group = create(:budget_group, budget: budget)
      last_heading = create(:budget_heading, group: group, name: "BBB")
      first_heading = create(:budget_heading, group: group, name: "AAA")

      visit budgets_path

      expect(first_heading.name).to appear_before(last_heading.name)
    end

    scenario "Show groups and headings for missing translations" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group1)
      heading2 = create(:budget_heading, group: group2)

      visit budgets_path locale: :es

      within("#budget_info") do
        expect(page).to have_content group1.name
        expect(page).to have_content group2.name
        expect(page).to have_content heading1.name
        expect(page).to have_content budget.formatted_heading_price(heading1)
        expect(page).to have_content heading2.name
        expect(page).to have_content budget.formatted_heading_price(heading2)
      end
    end

    scenario "Show informing index without links" do
      budget.update_attributes(phase: "informing")
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      visit budgets_path

      within("#budget_info") do
        expect(page).not_to have_link "#{heading.name} €1,000,000"
        expect(page).to have_content "#{heading.name} €1,000,000"

        expect(page).not_to have_link("List of all investment projects")
        expect(page).not_to have_link("List of all unfeasible investment projects")
        expect(page).not_to have_link("List of all investment projects not selected for balloting")

        expect(page).not_to have_css("div.map")
      end
    end

    scenario "Show finished index without heading links" do
      budget.update_attributes(phase: "finished")
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      visit budgets_path

      within("#budget_info") do
        expect(page).not_to have_link "#{heading.name} €1,000,000"
        expect(page).to have_content "#{heading.name} €1,000,000"

        expect(page).to have_link "List of all investment projects",
                                   href: budget_path(budget)

        expect(page).to have_link "List of all unfeasible investment projects",
                                   href: budget_path(budget, filter: "unfeasible")

        expect(page).to have_link "List of all investment projects not selected for balloting",
                                   href: budget_path(budget, filter: "unselected")

        expect(page).to have_css("div.map")
      end
    end

    scenario "Show investment links only on balloting or later" do

      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)

      allowed_phase_list.each do |phase|
        budget.update(phase: phase)

        visit budgets_path

        expect(page).to have_content(I18n.t("budgets.index.investment_proyects"))
        expect(page).to have_content(I18n.t("budgets.index.unfeasible_investment_proyects"))
        expect(page).to have_content(I18n.t("budgets.index.not_selected_investment_proyects"))
      end
    end

    scenario "Not show investment links earlier of balloting " do

      budget = create(:budget)
      group = create(:budget_group, budget: budget)
      heading = create(:budget_heading, group: group)
      phases_without_links = ["drafting", "informing"]
      not_allowed_phase_list = Budget::Phase::PHASE_KINDS -
                               phases_without_links -
                               allowed_phase_list

      not_allowed_phase_list.each do |phase|
        budget.update(phase: phase)

        visit budgets_path

        expect(page).not_to have_content(I18n.t("budgets.index.investment_proyects"))
        expect(page).to have_content(I18n.t("budgets.index.unfeasible_investment_proyects"))
        expect(page).not_to have_content(I18n.t("budgets.index.not_selected_investment_proyects"))
      end
    end

    scenario "No budgets" do
      Budget.destroy_all

      visit budgets_path

      expect(page).to have_content "There are no budgets"
    end

    scenario "Accepting" do
      budget.update(phase: "accepting")
      login_as(create(:user, :level_two))

      visit budgets_path

      expect(page).to have_link "Create a budget investment"
    end
  end

  scenario "Index shows only published phases" do

    budget.update(phase: :finished)
    phases = budget.phases
    phases.drafting.update(starts_at: "30-12-2017", ends_at: "31-12-2017", enabled: true,
                           description: "Description of drafting phase",
                           summary: "<p>This is the summary for drafting phase</p>")

    phases.accepting.update(starts_at: "01-01-2018", ends_at: "10-01-2018", enabled: true,
                            description: "Description of accepting phase",
                            summary: "This is the summary for accepting phase")

    phases.reviewing.update(starts_at: "11-01-2018", ends_at: "20-01-2018", enabled: false,
                            description: "Description of reviewing phase",
                            summary: "This is the summary for reviewing phase")

    phases.selecting.update(starts_at: "21-01-2018", ends_at: "01-02-2018", enabled: true,
                            description: "Description of selecting phase",
                            summary: "This is the summary for selecting phase")

    phases.valuating.update(starts_at: "10-02-2018", ends_at: "20-02-2018", enabled: false,
                            description: "Description of valuating phase",
                            summary: "This is the summary for valuating phase")

    phases.publishing_prices.update(starts_at: "21-02-2018", ends_at: "01-03-2018", enabled: false,
                                    description: "Description of publishing prices phase",
                                    summary: "This is the summary for publishing_prices phase")

    phases.balloting.update(starts_at: "02-03-2018", ends_at: "10-03-2018", enabled: true,
                            description: "Description of balloting phase",
                            summary: "This is the summary for balloting phase")

    phases.reviewing_ballots.update(starts_at: "11-03-2018", ends_at: "20-03-2018", enabled: false,
                                    description: "Description of reviewing ballots phase",
                                    summary: "This is the summary for reviewing_ballots phase")

    phases.finished.update(starts_at: "21-03-2018", ends_at: "30-03-2018", enabled: true,
                           description: "Description of finished phase",
                           summary: "This is the summary for finished phase")

    visit budgets_path

    expect(page).not_to have_content "This is the summary for drafting phase"
    expect(page).not_to have_content "December 30, 2017 - December 31, 2017"
    expect(page).not_to have_content "This is the summary for reviewing phase"
    expect(page).not_to have_content "January 11, 2018 - January 20, 2018"
    expect(page).not_to have_content "This is the summary for valuating phase"
    expect(page).not_to have_content "February 10, 2018 - February 20, 2018"
    expect(page).not_to have_content "This is the summary for publishing_prices phase"
    expect(page).not_to have_content "February 21, 2018 - March 01, 2018"
    expect(page).not_to have_content "This is the summary for reviewing_ballots phase"
    expect(page).not_to have_content "March 11, 2018 - March 20, 2018"

    expect(page).to have_content "This is the summary for accepting phase"
    expect(page).to have_content "January 01, 2018 - January 20, 2018"
    expect(page).to have_content "This is the summary for selecting phase"
    expect(page).to have_content "January 21, 2018 - March 01, 2018"
    expect(page).to have_content "This is the summary for balloting phase"
    expect(page).to have_content "March 02, 2018 - March 20, 2018"
    expect(page).to have_content "This is the summary for finished phase"
    expect(page).to have_content "March 21, 2018 - March 29, 2018"

    expect(page).to have_css(".phase.is-active", count: 1)
  end

  context "Index map" do

    let(:group)   { create(:budget_group, budget: budget) }
    let(:heading) { create(:budget_heading, group: group) }

    before do
      Setting["feature.map"] = true
    end

    scenario "Display investment's map location markers", :js do
      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      create(:map_location, longitude: 0.1, latitude: 51.48, investment: investment1)

      create(:map_location, longitude: -0.1, latitude: 51.48, investment: investment2)
      create(:map_location, longitude: -0.1, latitude: 51.49, investment: investment3)
      create(:map_location, longitude: -0.1, latitude: 51.50, investment: investment4)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 1)
        expect(page).to have_css(".marker-cluster div span", text: "3")
      end
    end

    scenario "Display all investment's map location if there are no selected", :js do
      budget.update(phase: :publishing_prices)

      investment1 = create(:budget_investment, heading: heading)
      investment2 = create(:budget_investment, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 0, latitude: 51.48, zoom: 10)
      investment2.create_map_location(longitude: 0, latitude: 51.49, zoom: 10)
      investment3.create_map_location(longitude: 0, latitude: 51.50, zoom: 10)
      investment4.create_map_location(longitude: 0, latitude: 51.51, zoom: 10)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".marker-cluster div span", text: "4")
      end
    end

    scenario "Display only selected investment's map location from publishing prices phase", :js do
      budget.update(phase: :publishing_prices)

      investment1 = create(:budget_investment, :selected, heading: heading)
      investment2 = create(:budget_investment, :selected, heading: heading)
      investment3 = create(:budget_investment, heading: heading)
      investment4 = create(:budget_investment, heading: heading)

      investment1.create_map_location(longitude: 0, latitude: 51.48, zoom: 10)
      investment2.create_map_location(longitude: 0, latitude: 51.49, zoom: 10)
      investment3.create_map_location(longitude: 0, latitude: 51.50, zoom: 10)
      investment4.create_map_location(longitude: 0, latitude: 51.51, zoom: 10)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".marker-cluster div span", text: "2")
      end
    end

    scenario "Skip invalid map markers", :js do
      map_locations = []

      investment = create(:budget_investment, heading: heading)

      map_locations << { longitude: 0, latitude: 51.48 }
      map_locations << { longitude: 0, latitude: "********" }
      map_locations << { longitude: "**********", latitude: 51.49 }

      budget_map_locations = map_locations.map do |map_location|
        {
          lat: map_location[:latitude],
          long: map_location[:longitude],
          investment_title: investment.title,
          investment_id: investment.id,
          budget_id: budget.id
        }
      end

      allow_any_instance_of(BudgetsHelper).
      to receive(:current_budget_map_locations).and_return(budget_map_locations)

      visit budgets_path

      within ".map_location" do
        expect(page).to have_css(".map-icon", count: 1, visible: false)
      end
    end
  end

  context "Show" do

    scenario "List all groups" do
      group1 = create(:budget_group, budget: budget)
      group2 = create(:budget_group, budget: budget)

      visit budget_path(budget)

      budget.groups.each {|group| expect(page).to have_link(group.name)}
    end

    scenario "Links to unfeasible and selected if balloting or later" do
      budget = create(:budget, :selecting)
      group = create(:budget_group, budget: budget)

      visit budget_path(budget)

      expect(page).not_to have_link "See unfeasible investments"
      expect(page).not_to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).not_to have_link "See unfeasible investments"
      expect(page).not_to have_link "See investments not selected for balloting phase"

      budget.update(phase: :publishing_prices)

      visit budget_path(budget)

      expect(page).not_to have_link "See unfeasible investments"
      expect(page).not_to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).not_to have_link "See unfeasible investments"
      expect(page).not_to have_link "See investments not selected for balloting phase"

      budget.update(phase: :balloting)

      visit budget_path(budget)

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"

      budget.update(phase: :finished)

      visit budget_path(budget)

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"

      click_link group.name

      expect(page).to have_link "See unfeasible investments"
      expect(page).to have_link "See investments not selected for balloting phase"
    end

    scenario "Take into account headings with the same name from a different budget" do
      group1 = create(:budget_group, budget: budget, name: "New York")
      heading1 = create(:budget_heading, group: group1, name: "Brooklyn")
      heading2 = create(:budget_heading, group: group1, name: "Queens")

      budget2 = create(:budget)
      group2 = create(:budget_group, budget: budget2, name: "New York")
      heading3 = create(:budget_heading, group: group2, name: "Brooklyn")
      heading4 = create(:budget_heading, group: group2, name: "Queens")

      visit budget_path(budget)
      click_link "New York"

      expect(page).to have_css("#budget_heading_#{heading1.id}")
      expect(page).to have_css("#budget_heading_#{heading2.id}")

      expect(page).not_to have_css("#budget_heading_#{heading3.id}")
      expect(page).not_to have_css("#budget_heading_#{heading4.id}")
    end

    scenario "See results button is showed if the budget has finished for all users" do
      user = create(:user)
      admin = create(:administrator)
      budget = create(:budget, :finished)

      login_as(user)
      visit budget_path(budget)
      expect(page).to have_link "See results"

      logout

      login_as(admin.user)
      visit budget_path(budget)
      expect(page).to have_link "See results"
    end

    scenario "See results button isn't showed if the budget hasn't finished for all users" do
      user = create(:user)
      admin = create(:administrator)
      budget = create(:budget, :balloting)

      login_as(user)
      visit budget_path(budget)
      expect(page).not_to have_link "See results"

      logout

      login_as(admin.user)
      visit budget_path(budget)
      expect(page).not_to have_link "See results"
    end

  end

  context "In Drafting phase" do

    let(:admin) { create(:administrator).user }

    before do
      logout
      budget.update(phase: "drafting")
      create(:budget)
    end

    context "Listed" do
      scenario "Not listed at public budgets list" do
        visit budgets_path

        expect(page).not_to have_content(budget.name)
      end
    end

    context "Shown" do
      scenario "Not accesible to guest users" do
        expect { visit budget_path(budget) }.to raise_error(ActionController::RoutingError)
      end

      scenario "Not accesible to logged users" do
        login_as(level_two_user)

        expect { visit budget_path(budget) }.to raise_error(ActionController::RoutingError)
      end

      scenario "Is accesible to admin users" do
        login_as(admin)
        visit budget_path(budget)

        expect(page.status_code).to eq(200)
      end
    end

  end

  context "Accepting" do

    before do
      budget.update(phase: "accepting")
    end

    context "Permissions" do

      scenario "Verified user" do
        login_as(level_two_user)

        visit budget_path(budget)
        expect(page).to have_link "Create a budget investment"

      end

      scenario "Unverified user" do
        user = create(:user)
        login_as(user)

        visit budget_path(budget)

        expect(page).to have_content "To create a new budget investment verify your account."
      end

      scenario "user not logged in" do
        visit budget_path(budget)

        expect(page).to have_content "To create a new budget investment you must sign in or sign up"
      end

    end
  end
end
