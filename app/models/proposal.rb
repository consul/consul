require "csv"

class Proposal < ApplicationRecord
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
  include Followable
  include Communitable
  include Imageable
  include Mappable
  include Notifiable
  include Documentable
  include EmbedVideosHelper
  include Relationable
  include Milestoneable
  include Randomizable

  acts_as_votable
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  RETIRE_OPTIONS = %w[duplicated started unfeasible done other]

  belongs_to :author, -> { with_hidden }, class_name: "User", foreign_key: "author_id"
  belongs_to :geozone
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :proposal_notifications, dependent: :destroy
  has_many :dashboard_executed_actions, dependent: :destroy, class_name: "Dashboard::ExecutedAction"
  has_many :dashboard_actions, through: :dashboard_executed_actions, class_name: "Dashboard::Action"
  has_many :polls, as: :related

  extend DownloadSettings::ProposalCsv
  delegate :name, :email, to: :author, prefix: true

  extend DownloadSettings::ProposalCsv
  delegate :name, :email, to: :author, prefix: true

  validates :title, presence: true
  validates :summary, presence: true
  validates :author, presence: true
  validates :responsible_name, presence: true, unless: :skip_user_verification?

  validates :title, length: { in: 4..Proposal.title_max_length }
  validates :description, length: { maximum: Proposal.description_max_length }
  validates :responsible_name, length: { in: 6..Proposal.responsible_name_max_length }, unless: :skip_user_verification?
  validates :retired_reason, inclusion: { in: RETIRE_OPTIONS, allow_nil: true }

  validates :terms_of_service, acceptance: { allow_nil: false }, on: :create

  validate :valid_video_url?

  before_validation :set_responsible_name

  before_save :calculate_hot_score, :calculate_confidence_score

  after_create :send_new_actions_notification_on_create

  scope :for_render,               -> { includes(:tags) }
  scope :sort_by_hot_score,        -> { reorder(hot_score: :desc) }
  scope :sort_by_confidence_score, -> { reorder(confidence_score: :desc) }
  scope :sort_by_created_at,       -> { reorder(created_at: :desc) }
  scope :sort_by_most_commented,   -> { reorder(comments_count: :desc) }
  scope :sort_by_relevance,        -> { all }
  scope :sort_by_flags,            -> { order(flags_count: :desc, updated_at: :desc) }
  scope :sort_by_archival_date,    -> { archived.sort_by_confidence_score }
  scope :sort_by_recommendations,  -> { order(cached_votes_up: :desc) }
  scope :archived,                 -> { where("proposals.created_at <= ?", Setting["months_to_archive_proposals"].to_i.months.ago) }
  scope :not_archived,             -> { where("proposals.created_at > ?", Setting["months_to_archive_proposals"].to_i.months.ago) }
  scope :last_week,                -> { where("proposals.created_at >= ?", 7.days.ago)}
  scope :retired,                  -> { where.not(retired_at: nil) }
  scope :not_retired,              -> { where(retired_at: nil) }
  scope :successful,               -> { where("cached_votes_up >= ?", Proposal.votes_needed_for_success) }
  scope :unsuccessful,             -> { where("cached_votes_up < ?", Proposal.votes_needed_for_success) }
  scope :public_for_api,           -> { all }
  scope :selected,                 -> { where(selected: true) }
  scope :not_selected,             -> { where(selected: false) }
  scope :not_supported_by_user,    ->(user) { where.not(id: user.find_voted_items(votable_type: "Proposal").compact.map(&:id)) }
  scope :published,                -> { where.not(published_at: nil) }
  scope :draft,                    -> { where(published_at: nil) }
  scope :created_by,               ->(author) { where(author: author) }

  def url
    proposal_path(self)
  end

  def publish
    update(published_at: Time.now)
    send_new_actions_notification_on_published
  end

  def published?
    !published_at.nil?
  end

  def draft?
    published_at.nil?
  end

  def self.recommendations(user)
    tagged_with(user.interests, any: true)
      .where("author_id != ?", user.id)
      .unsuccessful
      .not_followed_by_user(user)
      .not_archived
      .not_supported_by_user(user)
  end

  def self.not_followed_by_user(user)
    where.not(id: followed_by_user(user).pluck(:id))
  end

  def to_param
    "#{id}-#{title}".parameterize
  end

  def searchable_values
    { title              => "A",
      id.to_s            => "A",
      author.username    => "B",
      tag_list.join(" ") => "B",
      to_param()         => "B",
      geozone.try(:name) => "B",
      summary            => "C",
      description        => "D"
    }
  end

  def self.search(terms)
    terms = terms.to_s if terms.is_a? Numeric
    by_code = search_by_code(terms.strip)
    by_code.present? ? by_code : pg_search(terms)
  end

  def self.search_by_code(terms)
    matched_code = match_code(terms)
    results = where(id: matched_code[1]) if matched_code
    return results if results.present? && results.first.code == terms
  end

  def self.match_code(terms)
    /\A#{Setting["proposal_code_prefix"]}-\d\d\d\d-\d\d-(\d*)\z/.match(terms)
  end

  def self.for_summary
    summary = {}
    categories = ActsAsTaggableOn::Tag.category_names.sort
    geozones   = Geozone.names.sort

    groups = categories + geozones
    groups.each do |group|
      summary[group] = search(group).last_week.sort_by_confidence_score.limit(3)
    end
    summary
  end

  def total_votes
    cached_votes_up
  end

  def voters
    User.active.where(id: votes_for.voters)
  end

  def editable?
    total_votes <= Setting["max_votes_for_proposal_edit"].to_i
  end

  def editable_by?(user)
    author_id == user.id && editable?
  end

  def votable_by?(user)
    user && user.level_two_or_three_verified?
  end

  def retired?
    retired_at.present?
  end

  def register_vote(user, vote_value)
    if votable_by?(user) && !archived?
      vote_by(voter: user, vote: vote_value)
    end
  end

  def code
    "#{Setting["proposal_code_prefix"]}-#{created_at.strftime("%Y-%m")}-#{id}"
  end

  def after_commented
    save # update cache when it has a new comment
  end

  def calculate_hot_score
    self.hot_score = ScoreCalculator.hot_score(self)
  end

  def calculate_confidence_score
    self.confidence_score = ScoreCalculator.confidence_score(total_votes, total_votes)
  end

  def after_hide
    tags.each{ |t| t.decrement_custom_counter_for("Proposal") }
  end

  def after_restore
    tags.each{ |t| t.increment_custom_counter_for("Proposal") }
  end

  def self.votes_needed_for_success
    Setting["votes_for_proposal_success"].to_i
  end

  def successful?
    total_votes >= Proposal.votes_needed_for_success
  end

  def archived?
    created_at <= Setting["months_to_archive_proposals"].to_i.months.ago
  end

  def notifications
    proposal_notifications
  end

  def users_to_notify
    (voters + followers).uniq - [author]
  end

  def self.proposals_orders(user)
    orders = %w[hot_score confidence_score created_at relevance archival_date]
    orders << "recommendations" if Setting["feature.user.recommendations_on_proposals"] && user&.recommended_proposals
    return orders
  end

  def skip_user_verification?
    Setting["feature.user.skip_verification"].present?
  end

  def send_new_actions_notification_on_create
    new_actions = Dashboard::Action.detect_new_actions_since(Date.yesterday, self)

    if new_actions.present?
      Dashboard::Mailer.delay.new_actions_notification_on_create(self)
    end
  end

  def send_new_actions_notification_on_published
    new_actions_ids = Dashboard::Action.detect_new_actions_since(Date.yesterday, self)

    if new_actions_ids.present?
      Dashboard::Mailer.delay.new_actions_notification_on_published(self, new_actions_ids)
    end
  end

  protected

    def set_responsible_name
      if author && author.document_number?
        self.responsible_name = author.document_number
      end
    end

end
