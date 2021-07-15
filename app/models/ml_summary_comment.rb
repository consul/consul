class MlSummaryComment < ApplicationRecord
  belongs_to :commentable, -> { with_hidden }, polymorphic: true, touch: true
end
