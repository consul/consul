require "spec_helper"

shared_examples_for "globalizable" do |factory_name|
  let(:record) do
    if factory_name == :budget_phase
      create(:budget).phases.last
    else
      create(factory_name)
    end
  end
  let(:fields) { record.translated_attribute_names }
  let(:required_fields) { fields.select { |field| record.send(:required_attribute?, field) } }
  let(:attribute) { required_fields.sample || fields.sample }

  before do
    if factory_name == :budget || factory_name == :budget_phase
      record.main_link_url = "https://consulproject.org"
    end
    record.update!(attribute => "In English")

    I18n.with_locale(:es) do
      record.update!(required_fields.map { |field| [field, "En español"] }.to_h)
      record.update!(attribute => "En español")
    end

    record.reload
  end

  describe "Add a translation" do
    it "Maintains existing translations" do
      record.update!(translations_attributes: [
        { locale: :fr }.merge(fields.map { |field| [field, "En Français"] }.to_h)
      ])
      record.reload

      expect(record.send(attribute)).to eq "In English"
      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "En español" }
      I18n.with_locale(:fr) { expect(record.send(attribute)).to eq "En Français" }
    end

    it "Works with non-underscored locale name" do
      record.update!(translations_attributes: [
        { locale: :"pt-BR" }.merge(fields.map { |field| [field, "Português"] }.to_h)
      ])
      record.reload

      expect(record.send(attribute)).to eq "In English"
      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "En español" }
      I18n.with_locale(:"pt-BR") { expect(record.send(attribute)).to eq "Português" }
    end

    it "Does not create invalid translations in the database" do
      skip("cannot have invalid translations") if required_fields.empty?

      record.update(translations_attributes: [{ locale: :fr }])

      expect(record.translations.map(&:locale)).to match_array %i[en es fr]

      record.reload

      expect(record.translations.map(&:locale)).to match_array %i[en es]
    end

    it "Does not automatically add a translation for the current locale" do
      record.translations.destroy_all
      record.reload

      record.update!(translations_attributes: [
        { locale: :de }.merge(fields.map { |field| [field, "Deutsche Sprache"] }.to_h)
      ])

      record.reload

      expect(record.translations.map(&:locale)).to eq [:de]
    end
  end

  describe "Update a translation" do
    it "Changes the existing translation" do
      record.update!(translations_attributes: [
        { id: record.translations.find_by(locale: :es).id, attribute => "Actualizado" }
      ])
      record.reload

      expect(record.send(attribute)).to eq "In English"
      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "Actualizado" }
    end

    it "Does not save invalid translations" do
      skip("cannot have invalid translations") if required_fields.empty?

      record.update(translations_attributes: [
        { id: record.translations.find_by(locale: :es).id, attribute => "" }
      ])

      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "" }

      record.reload

      I18n.with_locale(:es) { expect(record.send(attribute)).to eq "En español" }
    end

    it "Does not automatically add a translation for the current locale" do
      record.translations.find_by(locale: :en).destroy!
      record.reload

      record.update!(translations_attributes: [
        { id: record.translations.first.id }.merge(fields.map { |field| [field, "Actualizado"] }.to_h)
      ])

      record.reload

      expect(record.translations.map(&:locale)).to eq [:es]
    end
  end

  describe "Remove a translation" do
    it "Keeps the other languages" do
      record.update!(translations_attributes: [
        { id: record.translations.find_by(locale: :en).id, _destroy: true }
      ])
      record.reload

      expect(record.translations.map(&:locale)).to eq [:es]
    end

    it "Does not remove all translations" do
      skip("cannot have invalid translations") if required_fields.empty?

      record.translations_attributes = [
        { id: record.translations.find_by(locale: :en).id, _destroy: true },
        { id: record.translations.find_by(locale: :es).id, _destroy: true }
      ]

      expect(record).not_to be_valid

      record.reload

      expect(record.translations.map(&:locale)).to match_array %i[en es]
    end

    it "Does not remove translations when there's invalid data" do
      skip("cannot have invalid translations") if required_fields.empty?

      record.translations_attributes = [
        { id: record.translations.find_by(locale: :es).id, attribute => "" },
        { id: record.translations.find_by(locale: :en).id, _destroy: true }
      ]

      expect(record).not_to be_valid

      record.reload

      expect(record.translations.map(&:locale)).to match_array %i[en es]
    end
  end

  describe "Fallbacks" do
    before do
      I18n.with_locale(:de) do
        record.update!(required_fields.map { |field| [field, "Deutsche Sprache"] }.to_h)
        record.update!(attribute => "Deutsche Sprache")
      end
    end

    it "Falls back to a defined fallback" do
      allow(I18n.fallbacks).to receive(:[]).and_return([:fr, :es])
      Globalize.set_fallbacks_to_all_available_locales

      I18n.with_locale(:fr) do
        expect(record.send(attribute)).to eq "En español"
      end
    end

    it "Falls back to the first available locale without a defined fallback" do
      allow(I18n.fallbacks).to receive(:[]).and_return([:fr])
      Globalize.set_fallbacks_to_all_available_locales

      I18n.with_locale(:fr) do
        expect(record.send(attribute)).to eq "Deutsche Sprache"
      end
    end

    it "Falls back to the first available locale after removing a locale" do
      expect(record.send(attribute)).to eq "In English"

      record.update!(translations_attributes: [
        { id: record.translations.find_by(locale: :en).id, _destroy: true }
      ])

      expect(record.send(attribute)).to eq "Deutsche Sprache"
    end
  end
end
