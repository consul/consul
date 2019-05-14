class SignatureSheet < ActiveRecord::Base
  belongs_to :signable, polymorphic: true
  belongs_to :author, class_name: "User", foreign_key: "author_id"

  VALID_SIGNABLES = %w(Proposal Budget::Investment SpendingProposal)

  has_many :signatures

  validates :author, presence: true
  validates :signable_type, inclusion: {in: VALID_SIGNABLES}
  validates :required_fields_to_verify, presence: true
  validates :signable, presence: true
  validate  :signable_found

  def name
    "#{signable_name} #{signable_id}"
  end

  def signable_name
    I18n.t("activerecord.models.#{signable_type.underscore}", count: 1)
  end

  def verify_signatures
    parsed_required_fields_to_verify_groups.each do |required_fields_to_verify|
      document_number = required_fields_to_verify[0]
      date_of_birth = parse_date_of_birth(required_fields_to_verify)
      postal_code = parse_postal_code(required_fields_to_verify)

      signature = signatures.where(document_number: document_number,
                                   date_of_birth: date_of_birth,
                                   postal_code: postal_code).first_or_create
      signature.verify
    end
    update(processed: true)
  end

  def parsed_required_fields_to_verify_groups
    required_fields_to_verify.split(/[;]/).collect {|d| d.gsub(/\s+/, "") }.map { |group| group.split(/[,]/)}
  end

  def signable_found
    errors.add(:signable_id, :not_found) if errors.messages[:signable].present?
  end

  private

  def parse_date_of_birth(required_fields_to_verify)
    return required_fields_to_verify[1] if Setting["remote_census_request.alias_date_of_birth"].present?
    nil
  end

  def parse_postal_code(required_fields_to_verify)
    if Setting["remote_census_request.alias_date_of_birth"].present? &&
        Setting["remote_census_request.alias_postal_code"].present?
      return required_fields_to_verify[2]
    elsif Setting["remote_census_request.alias_postal_code"].present?
      return required_fields_to_verify[1]
    else
      return nil
    end
  end
end
