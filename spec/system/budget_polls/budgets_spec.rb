require "rails_helper"

describe "Admin Budgets", :admin do
  context "Index" do
    scenario "Create poll if the budget does not have a poll associated" do
      budget = create(:budget)
      balloting_phase = budget.phases.balloting

      visit admin_budgets_path

      click_link "Ballots"

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content(budget.name)
      expect(page).to have_content(balloting_phase.starts_at.to_date)
      expect(page).to have_content(balloting_phase.ends_at.to_date)
    end

    scenario "Create poll in current locale if the budget does not have a poll associated" do
      create(:budget,
             name_en: "Budget for climate change",
             name_fr: "Budget pour le changement climatique")

      visit admin_budgets_path
      select_language "Français"

      click_link "Bulletins de l’admin"

      expect(page).to have_current_path(/admin\/polls\/\d+/)
      expect(page).to have_content("Budget pour le changement climatique")
    end

    scenario "Display link to poll if the budget has a poll associated" do
      budget = create(:budget)
      poll = create(:poll, budget: budget)

      visit admin_budgets_path

      within "#budget_#{budget.id}" do
        expect(page).to have_link "Ballots", href: admin_poll_booth_assignments_path(poll)
      end
    end
  end

  context "Show" do
    scenario "Do not show questions section if the budget have a poll associated" do
      poll = create(:poll, :for_budget)

      visit admin_poll_path(poll)

      within "#poll-resources" do
        expect(page).not_to have_content("Questions")
        expect(page).to have_content("Booths")
        expect(page).to have_content("Officers")
        expect(page).to have_content("Recounting")
        expect(page).to have_content("Results")
      end
    end
  end
end
