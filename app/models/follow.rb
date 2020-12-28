class Follow < ApplicationRecord
  belongs_to :user
  belongs_to :followable, polymorphic: true

  validates :user_id, presence: true
  validates :followable, presence: true
end
