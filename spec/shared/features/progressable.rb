shared_examples "progressable" do |factory_name, path_name|
  feature "Progress bars", :js do
    let!(:progressable) { create(factory_name) }
    let(:path) { send(path_name, *resource_hierarchy_for(progressable)) }

    scenario "With main progress bar" do
      create(:progress_bar, progressable: progressable)

      visit path

      find("#tab-milestones-label").click

      within("#tab-milestones") do
        expect(page).to have_css "progress"
      end
    end

    scenario "With main and secondary progress bar" do
      create(:progress_bar, progressable: progressable)
      create(:progress_bar, :secondary, progressable: progressable, title: "Build laboratory")

      visit path

      find("#tab-milestones-label").click

      within("#tab-milestones") do
        expect(page).to have_css "progress"
        expect(page).to have_content "Build laboratory"
      end
    end

    scenario "No main progress bar" do
      create(:progress_bar, :secondary, progressable: progressable, title: "Defeat Evil Lords")

      visit path

      find("#tab-milestones-label").click

      within("#tab-milestones") do
        expect(page).not_to have_content "Defeat Evil Lords"
      end
    end
  end
end
