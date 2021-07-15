class MachineLearningJob < ApplicationRecord
  belongs_to :user

  def started?
    started_at.present?
  end

  def finished?
    finished_at.present?
  end

  def errored?
    error.present?
  end

  def running_for_too_long?
    started? && !finished? && started_at < 1.day.ago
  end
end
