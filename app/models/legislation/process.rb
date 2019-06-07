class Legislation::Process < ApplicationRecord
  include ActsAsParanoidAliases
  include Taggable
  include Milestoneable
  include Imageable
  include Documentable

  acts_as_paranoid column: :hidden_at
  acts_as_taggable_on :customs

  translates :title,              touch: true
  translates :summary,            touch: true
  translates :description,        touch: true
  translates :additional_info,    touch: true
  translates :milestones_summary, touch: true
  translates :homepage,           touch: true
  include Globalizable

  PHASES_AND_PUBLICATIONS = %i[homepage_phase draft_phase debate_phase allegations_phase
                               proposals_phase draft_publication result_publication].freeze

  CSS_HEX_COLOR = /\A#?(?:[A-F0-9]{3}){1,2}\z/i

  has_many :draft_versions, -> { order(:id) }, class_name: "Legislation::DraftVersion",
                                               foreign_key: "legislation_process_id",
                                               dependent: :destroy
  has_one :final_draft_version, -> { where final_version: true, status: "published" },
                                           class_name: "Legislation::DraftVersion",
                                           foreign_key: "legislation_process_id"
  has_many :questions, -> { order(:id) }, class_name: "Legislation::Question",
                                          foreign_key: "legislation_process_id", dependent: :destroy
  has_many :proposals, -> { order(:id) }, class_name: "Legislation::Proposal",
                                          foreign_key: "legislation_process_id", dependent: :destroy

  validates_translation :title, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :debate_start_date, presence: true, if: :debate_end_date?
  validates :debate_end_date, presence: true, if: :debate_start_date?
  validates :draft_start_date, presence: true, if: :draft_end_date?
  validates :draft_end_date, presence: true, if: :draft_start_date?
  validates :allegations_start_date, presence: true, if: :allegations_end_date?
  validates :allegations_end_date, presence: true, if: :allegations_start_date?
  validates :proposals_phase_end_date, presence: true, if: :proposals_phase_start_date?
  validates :title_label, presence: true
  validates :summary_label, presence: true
  validates :description_label, presence:true, if: :description_enabled?
  validates :video_url_label, presence: true, if: :video_url_enabled?
  validates :image_label, presence: true, if: :image_enabled?
  validates :documents_label, presence: true, if: :documents_enabled?
  validates :geozone_label, presence: true, if: :geozone_enabled?
  validates :tags_label, presence: true, if: :tags_enabled?
  validate :valid_date_ranges
  validates :background_color, format: { allow_blank: true, with: CSS_HEX_COLOR }
  validates :font_color, format: { allow_blank: true, with: CSS_HEX_COLOR }

  scope :open, -> { where("start_date <= ? and end_date >= ?", Date.current, Date.current) }
  scope :active, -> { where("end_date >= ?", Date.current) }
  scope :past, -> { where("end_date < ?", Date.current) }

  scope :published, -> { where(published: true) }
  scope :not_in_draft, -> { where("draft_phase_enabled = false or (draft_start_date IS NOT NULL and
                                   draft_end_date IS NOT NULL and (draft_start_date > ? or
                                   draft_end_date < ?))", Date.current, Date.current) }

  def homepage_phase
    Legislation::Process::Phase.new(start_date, end_date, homepage_enabled)
  end

  def draft_phase
    Legislation::Process::Phase.new(draft_start_date, draft_end_date, draft_phase_enabled)
  end

  def debate_phase
    Legislation::Process::Phase.new(debate_start_date, debate_end_date, debate_phase_enabled)
  end

  def allegations_phase
    Legislation::Process::Phase.new(allegations_start_date,
                                    allegations_end_date, allegations_phase_enabled)
  end

  def proposals_phase
    Legislation::Process::Phase.new(proposals_phase_start_date,
                                    proposals_phase_end_date, proposals_phase_enabled)
  end

  def draft_publication
    Legislation::Process::Publication.new(draft_publication_date, draft_publication_enabled)
  end

  def result_publication
    Legislation::Process::Publication.new(result_publication_date, result_publication_enabled)
  end

  def enabled_phases?
    PHASES_AND_PUBLICATIONS.any? { |process| send(process).enabled? }
  end

  def enabled_phases_and_publications_count
    PHASES_AND_PUBLICATIONS.count { |process| send(process).enabled? }
  end

  def total_comments
    questions.sum(:comments_count) + draft_versions.map(&:total_comments).sum
  end

  def status
    today = Date.current

    if today < start_date
      :planned
    elsif end_date < today
      :closed
    else
      :open
    end
  end

  def title_label
    read_attribute(:title_label) || I18n.t("proposals.form.proposal_title")
  end

  def summary_label
    read_attribute(:summary_label) || I18n.t("proposals.form.proposal_summary")  end

  def description_label
    read_attribute(:description_label) || I18n.t("proposals.form.proposal_text")
  end

  def video_url_label
    read_attribute(:video_url_label) || I18n.t("proposals.form.proposal_video_url")
  end

  def image_label
    read_attribute(:image_label) || I18n.t("images.form.title")
  end

  def documents_label
    read_attribute(:documents_label) || I18n.t("documents.form.title")
  end

  def geozone_label
    read_attribute(:geozone_label) || I18n.t("proposals.form.geozone")
  end

  def tags_label
    read_attribute(:tags_label) || I18n.t("legislation.proposals.form.tags_label")
  end

  private

    def valid_date_ranges
      if end_date && start_date && end_date < start_date
        errors.add(:end_date, :invalid_date_range)
      end
      if debate_end_date && debate_start_date && debate_end_date < debate_start_date
        errors.add(:debate_end_date, :invalid_date_range)
      end
      if draft_end_date && draft_start_date && draft_end_date < draft_start_date
        errors.add(:draft_end_date, :invalid_date_range)
      end
      if allegations_end_date && allegations_start_date &&
         allegations_end_date < allegations_start_date
        errors.add(:allegations_end_date, :invalid_date_range)
      end
    end

end
