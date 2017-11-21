require 'rails_helper'

describe Verification::Residence do

  let!(:geozone) { create(:geozone, census_code: "01") }
  let(:residence) { build(:verification_residence, document_number: "12345678Z") }

  describe "validations" do

    it "should be valid" do
      expect(residence).to be_valid
    end

    describe "dates" do
      it "should be valid with a valid date of birth" do
        residence = Verification::Residence.new("date_of_birth(3i)" => "1", "date_of_birth(2i)" => "1", "date_of_birth(1i)" => "1980")
        expect(residence.errors[:date_of_birth].size).to eq(0)
      end

      it "should not be valid without a date of birth" do
        residence = Verification::Residence.new("date_of_birth(3i)" => "", "date_of_birth(2i)" => "", "date_of_birth(1i)" => "")
        expect(residence).to_not be_valid
        expect(residence.errors[:date_of_birth]).to include("can't be blank")
      end
    end

    it "should validate user has allowed age" do
      residence = Verification::Residence.new("date_of_birth(3i)" => "1",
                                              "date_of_birth(2i)" => "1",
                                              "date_of_birth(1i)" => 5.years.ago.year.to_s)
      expect(residence).to_not be_valid
      expect(residence.errors[:date_of_birth]).to include("You don't have the required age to participate")
    end

    it "should validate uniquness of document_number" do
      user = create(:user)
      residence.user = user
      residence.save

      build(:verification_residence)

      residence.valid?
      expect(residence.errors[:document_number]).to include("has already been taken")
    end

    it "should validate census terms" do
      residence.terms_of_service = nil
      expect(residence).to_not be_valid
    end

    describe "postal code" do
      let(:residence) { build(:verification_residence, document_number: '12345678Z') }
      before(:each) { Setting["postal_codes"] = "28001-28100,28200" }

      it "should be valid with postal codes included in settings" do
        residence.postal_code = "28012"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)

        residence.postal_code = "28200"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(0)
      end

      it "should not be valid with postal codes not included in settings" do
        residence.postal_code = "12345"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)

        residence.postal_code = "13280"
        residence.valid?
        expect(residence.errors[:postal_code].size).to eq(1)
        expect(residence.errors[:postal_code]).to include("In order to be verified, you must be registered.")
      end
    end

  end

  describe "new" do
    it "should upcase document number" do
      residence = Verification::Residence.new(document_number: "x1234567z")
      expect(residence.document_number).to eq("X1234567Z")
    end

    it "should remove all characters except numbers and letters" do
      residence = Verification::Residence.new(document_number: " 12.345.678 - B")
      expect(residence.document_number).to eq("12345678B")
    end
  end

  describe "save" do

    it "should store document number, document type, geozone, date of birth and gender" do
      user = create(:user)
      residence.user = user
      residence.save

      user.reload
      expect(user.document_number).to eq('12345678Z')
      expect(user.document_type).to eq("1")
      expect(user.date_of_birth.year).to eq(1980)
      expect(user.date_of_birth.month).to eq(12)
      expect(user.date_of_birth.day).to eq(31)
      expect(user.gender).to eq('male')
      expect(user.geozone).to eq(geozone)
    end

  end

  describe "tries" do
    it "should increase tries after a call to the Census" do
      residence.postal_code = "28011"
      residence.valid?
      expect(residence.user.lock.tries).to eq(1)
    end

    it "should not increase tries after a validation error" do
      residence.postal_code = ""
      residence.valid?
      expect(residence.user.lock).to be nil
    end
  end

  describe "Failed census call" do
    it "stores failed census API calls" do
      residence = build(:verification_residence, :invalid, document_number: "12345678Z")
      residence.save

      expect(FailedCensusCall.count).to eq(1)
      expect(FailedCensusCall.first).to have_attributes(
        user_id:         residence.user.id,
        document_number: "12345678Z",
        document_type:   "1",
        date_of_birth:   Date.new(1980, 12, 31),
        postal_code:     "28001"
      )
    end
  end

end
