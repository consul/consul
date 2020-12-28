class Poll
  class Voter < ApplicationRecord
    VALID_ORIGINS = %w[web booth letter].freeze

    belongs_to :poll
    belongs_to :user
    belongs_to :geozone
    belongs_to :booth_assignment
    belongs_to :officer_assignment
    belongs_to :officer

    validates :poll, presence: true
    validates :user_id, presence: true
    validates :booth_assignment_id, presence: true, if: ->(voter) { voter.origin == "booth" }
    validates :officer_assignment_id, presence: true, if: ->(voter) { voter.origin == "booth" }

    validates :document_number, presence: true, unless: :skip_user_verification?
    validates :user_id, uniqueness: { scope: [:poll_id], message: :has_voted }
    validates :origin, inclusion: { in: VALID_ORIGINS }

    before_validation :set_demographic_info, :set_document_info, :set_denormalized_booth_assignment_id

    scope :web,    -> { where(origin: "web") }
    scope :booth,  -> { where(origin: "booth") }
    scope :letter, -> { where(origin: "letter") }

    def set_demographic_info
      return if user.blank?

      self.gender  = user.gender
      self.age     = user.age
      self.geozone = user.geozone
    end

    def set_document_info
      return if user.blank?

      self.document_type   = user.document_type
      self.document_number = user.document_number
    end

    def skip_user_verification?
      Setting["feature.user.skip_verification"].present?
    end

    private

      def set_denormalized_booth_assignment_id
        self.booth_assignment_id ||= officer_assignment&.booth_assignment_id
      end
  end
end
