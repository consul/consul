class ProposalNotification < ApplicationRecord
  include Graphqlable
  include Notifiable
  include Searchable

  belongs_to :author, class_name: "User"
  belongs_to :proposal

  validates :title, presence: true
  validates :body, presence: true
  validates :proposal, presence: true
  validate :minimum_interval

  scope :public_for_api,     -> { where(proposal_id: Proposal.public_for_api.pluck(:id)) }
  scope :sort_by_created_at, -> { reorder(created_at: :desc) }
  scope :sort_by_moderated,  -> { reorder(moderated: :desc) }

  scope :moderated, -> { where(moderated: true) }
  scope :not_moderated, -> { where(moderated: false) }
  scope :pending_review, -> { moderated.where(ignored_at: nil) }
  scope :ignored, -> { moderated.where.not(ignored_at: nil) }

  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases

  after_create :set_author

  def minimum_interval
    return true if proposal&.notifications.blank?

    interval = Setting[:proposal_notification_minimum_interval_in_days]
    minimum_interval = (Time.current - interval.to_i.days).to_datetime
    if proposal.notifications.last.created_at > minimum_interval
      errors.add(:title, I18n.t("activerecord.errors.models.proposal_notification.attributes.minimum_interval.invalid", interval: interval))
    end
  end

  def notifiable
    proposal
  end

  def moderate_system_email(moderator)
    Notification.where(notifiable_type: "ProposalNotification", notifiable: self).destroy_all
    Activity.log(moderator, :hide, self)
  end

  def ignore_flag
    update(ignored_at: Time.current)
  end

  def ignored?
    ignored_at.present?
  end

  def after_restore
    update(moderated: false)
  end

  def searchable_values
    {
      title          => "A",
      body           => "B"
    }
  end

  def self.search(terms)
    pg_search(terms)
  end

  private

    def set_author
      self.update(author_id: self.proposal.author_id) if self.proposal
    end
end
