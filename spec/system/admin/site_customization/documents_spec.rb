require "rails_helper"

describe "Documents", :admin do
  scenario "Navigation" do
    visit admin_root_path

    within("#side_menu") do
      click_link "Site content"
      click_link "Custom documents"
    end

    expect(page).to have_link "Add new document",
                              href: new_admin_site_customization_document_path
  end

  scenario "Index" do
    3.times { create(:document, :admin) }
    1.times { create(:document) }

    document = Document.first
    attachment = document.attachment

    visit admin_site_customization_documents_path

    expect(page).to have_content "There are 3 documents"
    expect(page).to have_link document.title, href: attachment.url
  end

  scenario "Index (empty)" do
    visit admin_site_customization_documents_path

    expect(page).to have_content "There are no documents."
  end

  scenario "Index (pagination)" do
    per_page = 3
    allow(Document).to receive(:default_per_page).and_return(per_page)
    (per_page + 2).times { create(:document, :admin) }

    visit admin_site_customization_documents_path

    expect(page).to have_selector("#documents .document", count: per_page)

    within("ul.pagination") do
      expect(page).to have_content("1")
      expect(page).to have_link("2", href: admin_site_customization_documents_path(page: 2))
      expect(page).not_to have_content("3")
      click_link "Next", exact: false
    end

    expect(page).to have_selector("#documents .document", count: 2)
  end

  scenario "Create" do
    visit new_admin_site_customization_document_path

    attach_file("document_attachment", "#{Rails.root}/spec/fixtures/files/logo.pdf")
    click_button "Upload"

    expect(page).to have_content "Document uploaded succesfully"
    expect(page).to have_link "logo.pdf", href: Document.last.attachment.url
  end

  scenario "Errors on create" do
    visit new_admin_site_customization_document_path

    click_button "Upload"

    expect(page).to have_content "Invalid document"
  end

  scenario "Destroy" do
    document = create(:document, :admin)

    visit admin_site_customization_documents_path

    within("#document_#{document.id}") do
      accept_confirm("Delete: Are you sure?") { click_link "Delete" }
    end

    expect(page).to have_content "Document deleted succesfully"
    expect(page).not_to have_content document.title
  end
end
