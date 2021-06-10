require "numeric"

class Debate < ApplicationRecord
  include Rails.application.routes.url_helpers
  include Flaggable
  include Taggable
  include Conflictable
  include Measurable
  include Sanitizable
  include Searchable
  include Filterable
  include HasPublicAuthor
  include Graphqlable
  include Relationable
  include Notifiable
  include Randomizable
  include SDG::Relatable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  translates :title, touch: true
  translates :description, touch: true
  include Globalizable

  belongs_to :author, -> { with_hidden }, class_name: "User", inverse_of: :debates
  belongs_to :geozone
  has_many :comments, as: :commentable, inverse_of: :commentable

  validates_translation :title, presence: true, length: { in: 4..Debate.title_max_length }
  validates_translation :description, presence: true
  validate :description_sanitized
  validates :author, presence: true

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  before_save :calculate_hot_score, :calculate_confidence_score

  scope :for_render,               -> { includes(:tags) }
  scope :sort_by_hot_score,        -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_relevance,        -> { all }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :sort_by_recommendations,  -> { order(cached_votes_total: :desc) }
  scope :last_week,                -> { where("created_at >= ?", 7.days.ago) }
  scope :featured,                 -> { where("featured_at is not null") }
  scope :public_for_api,           -> { all }

  # Ahoy setup
  visitable # Ahoy will automatically assign visit_id on create

  attr_accessor :link_required

  def url
    debate_path(self)
  end

  def self.recommendations(user)
    tagged_with(user.interests, any: true)
      .where("author_id != ?", user.id)
  end

  def searchable_translations_definitions
    { title       => "A",
      description => "D" }
  end

  def searchable_values
    {
      author.username    => "B",
      tag_list.join(" ") => "B",
      geozone&.name      => "B"
    }.merge!(searchable_globalized_values)
  end

  def self.search(terms)
    pg_search(terms)
  end

  def to_param
    "#{id}-#{title}".parameterize
  end

  def likes
    cached_votes_up
  end

  def dislikes
    cached_votes_down
  end

  def total_votes
    cached_votes_total
  end

  def votes_score
    cached_votes_score
  end

  def total_anonymous_votes
    cached_anonymous_votes_total
  end

  def editable?
    total_votes <= Setting["max_votes_for_debate_edit"].to_i
  end

  def editable_by?(user)
    editable? && author == user
  end

  def register_vote(user, vote_value)
    if votable_by?(user)
      Debate.increment_counter(:cached_anonymous_votes_total, id) if user.unverified? && !user.voted_for?(self)
      vote_by(voter: user, vote: vote_value)
    end
  end

  def votable_by?(user)
    return false unless user

    total_votes <= 100 ||
      !user.unverified? ||
      Setting["max_ratio_anon_votes_on_debates"].to_i == 100 ||
      anonymous_votes_ratio < Setting["max_ratio_anon_votes_on_debates"].to_i ||
      user.voted_for?(self)
  end

  def anonymous_votes_ratio
    return 0 if cached_votes_total == 0

    (cached_anonymous_votes_total.to_f / cached_votes_total) * 100
  end

  def after_commented
    save # update cache when it has a new comment
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(self)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(cached_votes_total,
                                                             cached_votes_up)
  end

  def after_hide
    tags.each { |t| t.decrement_custom_counter_for("Debate") }
  end

  def after_restore
    tags.each { |t| t.increment_custom_counter_for("Debate") }
  end

  def featured?
    featured_at.present?
  end

  def self.debates_orders(user)
    orders = %w[hot_score confidence_score created_at relevance]
    orders << "recommendations" if Setting["feature.user.recommendations_on_debates"] && user&.recommended_debates
    orders
  end

  def description_sanitized
    real_description_length = ActionView::Base.full_sanitizer.sanitize("#{description}").squish.length
    if real_description_length < Debate.description_min_length
      errors.add(:description, :too_short, count: Debate.description_min_length)
    end
    if real_description_length > Debate.description_max_length
      errors.add(:description, :too_long, count: Debate.description_max_length)
    end
  end
end
