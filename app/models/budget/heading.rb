class Budget
  class Heading < ActiveRecord::Base
    OSM_DISTRICT_LEVEL_ZOOM = 12.freeze

    include Sluggable

    belongs_to :group
    belongs_to :geography

    has_many :investments
    has_many :content_blocks

    validates :group_id, presence: true
    validates :name, presence: true, uniqueness: { if: :name_exists_in_budget_headings }
    validates :price, presence: true
    validates :slug, presence: true, format: /\A[a-z0-9\-_]+\z/
    validates :population, numericality: { greater_than: 0 }, allow_nil: true
    validates :latitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?([1-8]?\d(?:\.\d{1,})?|90(?:\.0{1,6})?)\z/
    validates :longitude, length: { maximum: 22 }, allow_blank: true, \
              format: /\A(-|\+)?((?:1[0-7]|[1-9])?\d(?:\.\d{1,})?|180(?:\.0{1,})?)\z/

    delegate :budget, :budget_id, to: :group, allow_nil: true

    scope :order_by_group_name, -> { includes(:group).order('budget_groups.name', 'budget_headings.name') }
    scope :allow_custom_content, -> { where(allow_custom_content: true).order(:name) }

    def name_scoped_by_group
      group.single_heading_group? ? name : "#{group.name}: #{name}"
    end

    def name_exists_in_budget_headings
      group.budget.headings.where(name: name).where.not(id: id).any?
    end

    def can_be_deleted?
      investments.empty?
    end

    def whole_name
      group.budget.name + " - " + name
    end

    private

    def generate_slug?
      slug.nil? || budget.drafting?
    end

  end
end
