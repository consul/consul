require "rails_helper"

describe "Admin local census records", :admin do
  context "Index" do
    let!(:local_census_record) { create(:local_census_record) }

    scenario "Should show empty message when no local census records exists" do
      LocalCensusRecord.delete_all
      visit admin_local_census_records_path

      expect(page).to have_content("There are no local census records.")
    end

    scenario "Should show existing local census records" do
      visit admin_local_census_records_path

      expect(page).to have_content("DNI")
      expect(page).to have_content(local_census_record.document_number)
      expect(page).to have_content(local_census_record.date_of_birth)
      expect(page).to have_content(local_census_record.postal_code)
    end

    scenario "Should show edit and destroy actions for each record" do
      visit admin_local_census_records_path

      within "#local_census_record_#{local_census_record.id}" do
        expect(page).to have_link "Edit"
        expect(page).to have_link "Delete"
      end
    end

    scenario "Should show page entries info" do
      visit admin_local_census_records_path

      expect(page).to have_content("There is 1 local census record")
    end

    scenario "Should show paginator" do
      allow(LocalCensusRecord).to receive(:default_per_page).and_return(3)
      create_list(:local_census_record, 3)
      visit admin_local_census_records_path

      within ".pagination" do
        expect(page).to have_link("2")
      end
    end

    context "Search" do
      before do
        create(:local_census_record, document_number: "X66777888")
      end

      scenario "Should show matching records by document number at first visit" do
        visit admin_local_census_records_path(search: "X66777888")

        expect(page).to have_content "X66777888"
        expect(page).not_to have_content local_census_record.document_number
      end

      scenario "Should show matching records by document number" do
        visit admin_local_census_records_path

        fill_in :search, with: "X66777888"
        click_on "Search"

        expect(page).to have_content "X66777888"
        expect(page).not_to have_content local_census_record.document_number
      end
    end
  end

  context "Create" do
    scenario "Should show validation errors" do
      visit new_admin_local_census_record_path

      click_on "Save"

      expect(page).to have_content "4 errors prevented this Local Census Record from being saved."
      expect(page).to have_content "can't be blank", count: 4
    end

    scenario "Should show successful notice after create valid record" do
      visit new_admin_local_census_record_path

      select "DNI", from: :local_census_record_document_type
      fill_in :local_census_record_document_number, with: "#DOCUMENT"
      select "1982", from: :local_census_record_date_of_birth_1i
      select "July", from: :local_census_record_date_of_birth_2i
      select "7", from: :local_census_record_date_of_birth_3i
      fill_in :local_census_record_postal_code, with: "07003"
      click_on "Save"

      expect(page).to have_content "New local census record created successfully!"
      expect(page).to have_content "DNI"
      expect(page).to have_content "#DOCUMENT"
      expect(page).to have_content "1982-07-07"
      expect(page).to have_content "07003"
    end
  end

  context "Update" do
    let!(:local_census_record) { create(:local_census_record) }

    scenario "Should show validation errors" do
      visit edit_admin_local_census_record_path(local_census_record)

      fill_in :local_census_record_document_number, with: ""
      click_on "Save"

      expect(page).to have_content "1 error prevented this Local Census Record from being saved."
      expect(page).to have_content "can't be blank", count: 1
    end

    scenario "Should show successful notice after valid update" do
      visit edit_admin_local_census_record_path(local_census_record)

      select "Passport", from: :local_census_record_document_type
      fill_in :local_census_record_document_number, with: "#NIE_NUMBER"
      select "1982", from: :local_census_record_date_of_birth_1i
      select "August", from: :local_census_record_date_of_birth_2i
      select "8", from: :local_census_record_date_of_birth_3i
      fill_in :local_census_record_postal_code, with: "07007"
      click_on "Save"

      expect(page).to have_content "Local census record updated successfully!"
      expect(page).to have_content "Passport"
      expect(page).to have_content "#NIE_NUMBER"
      expect(page).to have_content "1982-08-08"
      expect(page).to have_content "07007"
    end
  end

  context "Destroy" do
    let!(:local_census_record) { create(:local_census_record) }
    let!(:deleted_document_number) { local_census_record.document_number }

    scenario "Should show successful destroy notice" do
      visit admin_local_census_records_path

      expect(page).to have_content deleted_document_number

      accept_confirm("Delete: Are you sure?") { click_on "Delete" }

      expect(page).to have_content "Local census record removed successfully!"
      expect(page).not_to have_content deleted_document_number
    end
  end
end
