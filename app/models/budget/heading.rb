class Budget
  class Heading < ApplicationRecord
    OSM_DISTRICT_LEVEL_ZOOM = 12

    include Sluggable

    translates :name, touch: true
    include Globalizable
    translation_class_delegate :budget

    class Translation
      validate :name_uniqueness_by_budget

      def name_uniqueness_by_budget
        if budget.headings
                 .joins(:translations)
                 .where(name: name)
                 .where.not("budget_heading_translations.budget_heading_id": budget_heading_id).any?
          errors.add(:name, I18n.t("errors.messages.taken"))
        end
      end
    end

    belongs_to :group

    has_many :investments
    has_many :content_blocks

    validates_translation :name, presence: true
    validates :group, presence: true
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :population, numericality: { greater_than: 0 }, allow_nil: true
    validates :latitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?([1-8]?\d(?:\.\d{1,})?|90(?:\.0{1,6})?)\z/
    validates :longitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?((?:1[0-7]|[1-9])?\d(?:\.\d{1,})?|180(?:\.0{1,})?)\z/
    validates :max_ballot_lines, numericality: { greater_than_or_equal_to: 1 }

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :allow_custom_content,  -> { where(allow_custom_content: true).sort_by(&:name) }

    def self.sort_by_name
      all.sort do |heading, other_heading|
        [other_heading.group.name, heading.name] <=> [heading.group.name, other_heading.name]
      end
    end

    def name_scoped_by_group
      group.single_heading_group? ? name : "#{group.name}: #{name}"
    end

    def can_be_deleted?
      investments.empty?
    end

    private

      def generate_slug?
        slug.nil? || budget.drafting?
      end
  end
end
