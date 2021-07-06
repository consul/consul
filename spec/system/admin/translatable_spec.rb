require "rails_helper"

describe "Admin edit translatable records", :admin do
  before do
    translatable.main_link_url = "https://consulproject.org" if translatable.is_a?(Budget::Phase)
    translatable.update!(attributes)
  end

  let(:fields) { translatable.translated_attribute_names }

  let(:attributes) do
    fields.product(%i[en es]).map do |field, locale|
      [:"#{field}_#{locale}", text_for(field, locale)]
    end.to_h
  end

  context "Add a translation" do
    context "Input fields" do
      let(:translatable) { create(:budget_heading) }
      let(:path) { admin_polymorphic_path(translatable, action: :edit) }

      scenario "Maintains existing translations" do
        visit path

        select "Français", from: :add_language
        fill_in "Heading name", with: "Nom en Français"
        click_button "Save heading"

        visit path

        expect(page).to have_field "Heading name", with: "Heading name in English"

        select "Español", from: :select_language

        expect(page).to have_field "Heading name", with: "Nombre de la partida en español"

        select "Français", from: :select_language

        expect(page).to have_field "Heading name", with: "Nom en Français"
      end
    end

    context "CKEditor fields" do
      let(:translatable) { create(:site_customization_page) }
      let(:path) { edit_admin_site_customization_page_path(translatable) }

      scenario "Maintains existing translations" do
        visit path

        select "Français", from: :add_language
        fill_in "Title", with: "Titre en Français"
        fill_in "Subtitle", with: "Sous-titres en Français"
        fill_in_ckeditor "Content", with: "Contenu en Français"
        click_button "Update Custom page"

        visit path

        expect(page).to have_ckeditor "Content", with: "Content in English"

        select "Español", from: :select_language

        expect(page).to have_ckeditor "Content", with: "Contenido en español"

        select "Français", from: :select_language

        expect(page).to have_ckeditor "Content", with: "Contenu en Français"
      end
    end

    context "Markdownit field" do
      let(:translatable) { create(:legislation_draft_version) }
      let(:path) { edit_admin_legislation_process_draft_version_path(translatable.process, translatable) }

      scenario "Maintains existing translations" do
        visit path

        select "Français", from: :add_language
        fill_in "Version title", with: "Titre en Français"
        click_link class: "fullscreen-toggle"
        fill_in "Text", with: "Texte en Français"
        click_link class: "fullscreen-toggle"
        click_button "Save changes"

        visit path
        click_link class: "fullscreen-toggle"

        expect(page).to have_field "Text", with: "Text in English"

        click_link class: "fullscreen-toggle"
        select "Español", from: :select_language
        click_link class: "fullscreen-toggle"

        expect(page).to have_field "Text", with: "Texto en español"

        click_link class: "fullscreen-toggle"
        select "Français", from: :select_language
        click_link class: "fullscreen-toggle"

        expect(page).to have_field "Text", with: "Texte en Français"
      end
    end

    context "Locale with non-underscored name" do
      let(:translatable) { create(:legislation_question) }
      let(:path) { edit_admin_legislation_process_question_path(translatable.process, translatable) }

      scenario "Adds a translation for that locale" do
        visit path

        select "Português brasileiro", from: :add_language
        fill_in "Question", with: "Português"
        click_button "Save changes"

        visit path
        select_language "Português brasileiro"

        expect(page).to have_field "Questão", with: "Português"
      end
    end
  end

  context "Add an invalid translation" do
    let(:translatable) { create(:budget_investment) }

    context "Input field" do
      let(:translatable) { create(:budget, main_link_url: "https://consulproject.org") }

      scenario "Shows validation erros" do
        visit edit_admin_budget_path(translatable)

        select "Français", from: :add_language
        fill_in "Name", with: ""
        click_button "Update Budget"

        expect(page).to have_css "#error_explanation"

        select "Français", from: :select_language

        expect(page).to have_field "Name", with: "", class: "is-invalid-input"
      end
    end

    context "CKEditor field" do
      let(:translatable) { create(:budget_investment) }

      scenario "Shows validation errors" do
        visit edit_admin_budget_budget_investment_path(translatable.budget, translatable)

        select "Français", from: :add_language
        fill_in "Title", with: "Titre en Français"
        fill_in_ckeditor "Description", with: ""
        click_button "Update"

        expect(page).to have_css "#error_explanation"

        select "Français", from: :select_language

        expect(page).to have_ckeditor "Description", with: ""
      end
    end

    context "Markdownit field" do
      let(:translatable) { create(:legislation_draft_version) }

      scenario "Shows validation errors" do
        visit edit_admin_legislation_process_draft_version_path(translatable.process, translatable)

        select "Français", from: :add_language
        fill_in "Version title", with: "Titre en Français"
        click_link class: "fullscreen-toggle"
        fill_in "Text", with: ""
        click_link class: "fullscreen-toggle"
        click_button "Save changes"

        expect(page).to have_css "#error_explanation"

        select "Français", from: :select_language
        click_link class: "fullscreen-toggle"

        expect(page).to have_field "Text", with: "", class: "is-invalid-input"
      end
    end
  end

  context "Update a translation" do
    context "Input fields" do
      let(:translatable) { create(:widget_card) }
      let(:path) { edit_admin_widget_card_path(translatable) }

      scenario "Changes the existing translation" do
        visit path

        select "Español", from: :select_language

        within(".translatable-fields") do
          fill_in "Title", with: "Título corregido"
          fill_in "Description", with: "Descripción corregida"
          fill_in "Link text", with: "Texto del enlace corregido"
          fill_in "Label (optional)", with: "Etiqueta corregida"
        end

        click_button "Save card"

        visit path

        expect(page).to have_field "Title", with: "Title in English"

        select_language "Español"

        expect(page).to have_field "Título", with: "Título corregido"
        expect(page).to have_field "Descripción", with: "Descripción corregida"
        expect(page).to have_field "Texto del enlace", with: "Texto del enlace corregido"
        expect(page).to have_field "Etiqueta (opcional)", with: "Etiqueta corregida"
      end
    end

    context "CKEditor fields" do
      let(:translatable) { create(:poll_question_answer) }
      let(:path) { edit_admin_answer_path(translatable) }

      scenario "Changes the existing translation" do
        visit path

        select "Español", from: :select_language

        within(".translatable-fields") do
          fill_in "Answer", with: "Respuesta corregida"
          fill_in_ckeditor "Description", with: "Descripción corregida"
        end

        click_button "Save"

        visit path

        expect(page).to have_field "Answer", with: "Answer in English"

        select_language "Español"

        expect(page).to have_field "Respuesta", with: "Respuesta corregida"
        expect(page).to have_ckeditor "Descripción", with: "Descripción corregida"
      end
    end

    context "Change value of a translated field to blank" do
      let(:translatable) { create(:poll) }
      let(:path) { edit_admin_poll_path(translatable) }

      scenario "Updates the field to a blank value" do
        visit path

        expect(page).to have_field "Summary", with: "Summary in English"

        fill_in "Summary", with: ""
        click_button "Update poll"

        visit path

        expect(page).to have_field "Summary", with: ""
      end
    end
  end

  context "Update a translation with invalid data" do
    context "Input fields" do
      let(:translatable) { create(:banner) }

      scenario "Show validation errors" do
        visit edit_admin_banner_path(translatable)
        select "Español", from: :select_language

        expect(page).to have_field "Title", with: "Title en español"

        fill_in "Title", with: ""
        click_button "Save changes"

        expect(page).to have_css "#error_explanation"

        select "Español", from: :select_language

        expect(page).to have_field "Title", with: "", class: "is-invalid-input"
      end
    end

    context "Markdownit field" do
      let(:translatable) { create(:legislation_draft_version) }

      scenario "Shows validation errors" do
        visit edit_admin_legislation_process_draft_version_path(translatable.process, translatable)

        select "Español", from: :select_language
        click_link class: "fullscreen-toggle"

        expect(page).to have_field "Text", with: "Texto en español"

        fill_in "Text", with: ""
        click_link class: "fullscreen-toggle"
        click_button "Save changes"

        expect(page).to have_css "#error_explanation"

        select "Español", from: :select_language
        click_link class: "fullscreen-toggle"

        expect(page).to have_field "Text", with: ""
      end
    end
  end

  context "Update a translation not having the current locale" do
    let(:translatable) { create(:legislation_process) }

    before do
      translatable.translations.destroy_all
      translatable.translations.create!(locale: :fr, title: "Titre en Français")
    end

    scenario "Does not add a translation for the current locale" do
      visit edit_admin_legislation_process_path(translatable)

      expect_to_have_language_selected "Français"
      expect_not_to_have_language "English"

      click_button "Save changes"

      expect(page).to have_content "Process updated successfully"

      visit edit_admin_legislation_process_path(translatable)

      expect_to_have_language_selected "Français"
      expect_not_to_have_language "English"
    end
  end

  context "Remove a translation" do
    let(:translatable) { create(:budget_group) }
    let(:path) { edit_admin_budget_group_path(translatable.budget, translatable) }

    scenario "Keeps the other languages" do
      visit path

      select "Español", from: :select_language
      click_link "Remove language"

      expect(page).not_to have_select :select_language, with_options: ["Español"]

      click_button "Save group"

      visit path

      expect(page).not_to have_select :select_language, with_options: ["Español"]
      expect(page).to have_select :select_language, with_options: ["English"]
    end
  end

  context "Remove all translations" do
    let(:translatable) { create(:milestone) }

    scenario "Shows an error message" do
      visit admin_polymorphic_path(translatable, action: :edit)

      click_link "Remove language"
      click_link "Remove language"

      click_button "Update milestone"

      expect(page).to have_content "Is mandatory to provide one translation at least"
    end
  end

  context "Remove a translation with invalid data" do
    let(:translatable) { create(:poll_question) }
    let(:path) { edit_admin_question_path(translatable) }

    scenario "Doesn't remove the translation" do
      visit path

      select "Español", from: :select_language
      click_link "Remove language"

      select "English", from: :select_language
      fill_in "Question", with: ""
      click_button "Save"

      expect(page).to have_css "#error_explanation"
      expect(page).to have_field "Question", with: "", class: "is-invalid-input"
      expect_to_have_language_selected "English"
      expect_not_to_have_language "Español"

      visit path
      select "Español", from: :select_language

      expect(page).to have_field "Question", with: "Pregunta en español"
    end
  end

  context "Current locale translation does not exist" do
    context "For all translatable except ActivePoll and Budget::Phase" do
      let(:translatable) { create(:admin_notification, segment_recipient: "all_users") }

      scenario "Shows first available fallback" do
        translatable.update!({ title_fr: "Titre en Français", body_fr: "Texte en Français" })

        visit edit_admin_admin_notification_path(translatable)

        select "English", from: :select_language
        click_link "Remove language"
        select "Español", from: :select_language
        click_link "Remove language"

        click_button "Update notification"

        expect(page).to have_content "Titre en Français"
      end
    end

    context "For Budget::Phase" do
      let(:translatable) { create(:budget).phases.last }

      scenario "Shows first available fallback" do
        translatable.update!({ name_fr: "Name en Français", description_fr: "Phase en Français" })

        visit edit_admin_budget_budget_phase_path(translatable.budget, translatable)

        select "English", from: :select_language
        click_link "Remove language"
        select "Español", from: :select_language
        click_link "Remove language"

        click_button "Save changes"

        visit budgets_path
        click_link "Name en Français"

        expect(page).to have_content "Phase en Français"
      end
    end

    context "For ActivePoll" do
      let(:translatable) { create(:active_poll) }

      scenario "Shows first available fallback" do
        translatable.update!({ description_fr: "Sondage en Français" })

        visit edit_admin_active_polls_path(translatable)

        select "English", from: :select_language
        click_link "Remove language"
        select "Español", from: :select_language
        click_link "Remove language"
        click_button "Save"

        visit polls_path

        expect(page).to have_content "Sondage en Français"
      end
    end
  end

  context "Globalize javascript interface" do
    let(:translatable) { create(:i18n_content) }
    let(:content) { translatable }
    let(:path) { admin_site_customization_information_texts_path }

    scenario "Select current locale when its translation exists" do
      visit path

      expect_to_have_language_selected "English"

      select_language "Español"

      expect_to_have_language_selected "Español"
    end

    scenario "Select first locale of existing translations when current locale translation does not exists" do
      content.translations.where(locale: :en).destroy_all
      visit path

      expect_to_have_language_selected "Español"
    end

    scenario "Show selected locale form" do
      visit path

      expect(page).to have_field "contents_content_#{content.key}values_value_en", with: "Value in English"

      select "Español", from: :select_language

      expect(page).to have_field "contents_content_#{content.key}values_value_es", with: "Value en español"
    end

    scenario "Select a locale and add it to the form" do
      visit path

      select "Français", from: :add_language

      expect_to_have_language_selected "Français"
      expect(page).to have_select :add_language, selected: "Add language"
      expect(page).to have_field "contents_content_#{content.key}values_value_fr"
    end

    context "Languages in use" do
      scenario "Show default description" do
        visit path

        expect(page).to have_content "2 languages in use"
      end

      scenario "Increase description count after add new language" do
        visit path

        select "Français", from: :add_language

        expect(page).to have_content "3 languages in use"
      end

      scenario "Decrease description count after remove a language" do
        visit path

        click_link "Remove language"

        expect(page).to have_content "1 language in use"
      end
    end

    context "When translation interface feature setting" do
      scenario "Is enabled translation interface should be rendered" do
        visit path

        expect(page).to have_css ".globalize-languages"
      end

      scenario "Is disabled translation interface should be rendered" do
        Setting["feature.translation_interface"] = nil

        visit path

        expect(page).to have_css ".globalize-languages"
      end
    end
  end
end
