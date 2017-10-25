class Legislation::Process < ActiveRecord::Base
  acts_as_paranoid column: :hidden_at
  include ActsAsParanoidAliases
  include HasPhases

  has_many :draft_versions, -> { order(:id) }, class_name: 'Legislation::DraftVersion',
                                               foreign_key: 'legislation_process_id', dependent: :destroy
  has_one :final_draft_version, -> { where final_version: true, status: 'published' }, class_name: 'Legislation::DraftVersion',
                                                                                       foreign_key: 'legislation_process_id'
  has_many :questions, -> { order(:id) }, class_name: 'Legislation::Question', foreign_key: 'legislation_process_id', dependent: :destroy

  validates :title, presence: true

  has_phase :debate, :allegations
  has_phase :global, start_date: :start_date,
                     end_date: :end_date,
                     phase_enabled: :published
  has_phase :draft, start_date: :draft_publication_date,
                    phase_enabled: :draft_publication_enabled,
                    publication: true,
                    phase_keyword: :publication
  has_phase :result, start_date: :result_publication_date,
                     phase_enabled: :result_publication_enabled,
                     publication: true,
                     phase_keyword: :publication

  delegate :status, to: :global_phase
  scope :open, -> { global_open }
  scope :next, -> { global_next }
  scope :past, -> { global_past }
  scope :published, -> { global_published }

  def total_comments
    questions.sum(:comments_count) + draft_versions.map(&:total_comments).sum
  end

end
