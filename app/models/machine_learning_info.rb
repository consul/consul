class MachineLearningInfo < ApplicationRecord
  class << self
    def for(kind)
      find_by(kind: kind)
    end
  end
end
