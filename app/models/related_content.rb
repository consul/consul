class RelatedContent < ApplicationRecord
  RELATED_CONTENT_SCORE_THRESHOLD = Setting["related_content_score_threshold"].to_f
  RELATIONABLE_MODELS = %w[proposals debates budgets investments].freeze

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  belongs_to :author, class_name: "User"
  belongs_to :parent_relationable, polymorphic: true, touch: true
  belongs_to :child_relationable, polymorphic: true, touch: true
  has_one :opposite_related_content, class_name: self.name, foreign_key: :related_content_id
  has_many :related_content_scores

  validates :parent_relationable, presence: true
  validates :child_relationable_id, presence: true
  validates :child_relationable_type, presence: true
  validates :parent_relationable_id, uniqueness: { scope: [:parent_relationable_type, :child_relationable_id, :child_relationable_type] }

  after_create :create_opposite_related_content, unless: proc { opposite_related_content.present? }
  after_create :create_author_score

  scope :not_hidden, -> { where(hidden_at: nil) }

  def score_positive(user)
    score(RelatedContentScore::SCORES[:POSITIVE], user)
  end

  def score_negative(user)
    score(RelatedContentScore::SCORES[:NEGATIVE], user)
  end

  def scored_by_user?(user)
    related_content_scores.exists?(user: user)
  end

  private

    def create_opposite_related_content
      related_content = RelatedContent.create!(opposite_related_content: self, parent_relationable: child_relationable,
                                               child_relationable: parent_relationable, author: author)
      self.opposite_related_content = related_content
    end

    def score(value, user)
      score_with_opposite(value, user)
      hide_with_opposite if (related_content_scores.sum(:value) / related_content_scores_count) < RELATED_CONTENT_SCORE_THRESHOLD
    end

    def hide_with_opposite
      hide
      opposite_related_content.hide
    end

    def create_author_score
      score_positive(author)
    end

    def score_with_opposite(value, user)
      RelatedContentScore.create(user: user, related_content: self, value: value)
      RelatedContentScore.create(user: user, related_content: opposite_related_content, value: value)
    end
end
