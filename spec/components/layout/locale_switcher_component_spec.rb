require "rails_helper"

describe Layout::LocaleSwitcherComponent, type: :component do
  let(:component) { Layout::LocaleSwitcherComponent.new }

  before do
    allow(request).to receive(:path_parameters).and_return(
      Rails.application.routes.recognize_path("/")
    )
  end

  context "with only one language" do
    before { allow(I18n).to receive(:available_locales).and_return([:en]) }

    it "doesn't render anything" do
      render_inline component

      expect(page.text).to be_empty
      expect(page).not_to have_css ".locale-switcher"
    end
  end

  context "with many languages" do
    before { allow(I18n).to receive(:available_locales).and_return(%i[de en es fr nl]) }

    it "renders a widget to select the language" do
      render_inline component

      expect(page).to have_css "ul.menu"
      expect(page.find("ul ul")).to have_link count: 5
    end

    it "selects the current locale" do
      render_inline component

      expect(page).to have_css "[aria-current]", count: 1
      expect(page).to have_css "[aria-current]", exact_text: "English"
    end

    context "missing language names" do
      let!(:default_enforce) { I18n.enforce_available_locales }

      before do
        I18n.enforce_available_locales = false
        allow(I18n).to receive(:available_locales).and_return(%i[de en es fr nl wl])
      end

      after { I18n.enforce_available_locales = default_enforce }

      it "renders the locale key" do
        render_inline component

        expect(page).to have_link "wl"
      end
    end
  end

  context "with a few languages" do
    before do
      allow(I18n).to receive(:available_locales).and_return(%i[en es fr])
    end

    it "renders a list of links" do
      render_inline component

      expect(page).to have_css "ul"
      expect(page).to have_link "English", href: "/?locale=en"
      expect(page).to have_link "Español", href: "/?locale=es"
      expect(page).to have_link "Français", href: "/?locale=fr"
      expect(page).not_to have_css "form"
    end

    it "marks the current locale" do
      render_inline component

      expect(page).to have_css "[aria-current]", count: 1
      expect(page).to have_css "[aria-current]", exact_text: "English"
    end
  end
end
