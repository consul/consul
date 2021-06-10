require "rails_helper"

describe "Documents", :admin do
  context "Index" do
    scenario "Answer with no documents" do
      answer = create(:poll_question_answer)
      document = create(:document)

      visit admin_answer_documents_path(answer)

      expect(page).not_to have_content(document.title)
    end

    scenario "Answer with documents" do
      answer = create(:poll_question_answer)
      document = create(:document, documentable: answer)

      visit admin_answer_documents_path(answer)

      expect(page).to have_content(document.title)
    end
  end

  scenario "Remove document from answer" do
    answer = create(:poll_question_answer)
    document = create(:document, documentable: answer)

    visit admin_answer_documents_path(answer)
    expect(page).to have_content(document.title)

    accept_confirm("Delete: Are you sure?") { click_link "Delete" }

    expect(page).not_to have_content(document.title)
  end
end
