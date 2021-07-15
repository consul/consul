module Relationable
  extend ActiveSupport::Concern

  included do
    has_many :related_contents,
      as:         :parent_relationable,
      inverse_of: :parent_relationable,
      dependent:  :destroy
  end

  def find_related_content(relationable)
    RelatedContent.find_by(parent_relationable: self, child_relationable: relationable)
  end

  def relationed_contents
    if Setting["machine_learning.related_content"]
      related_content = related_contents.not_hidden.order(machine_learning_score: :desc)
    else
      related_content = related_contents.not_hidden.from_users
    end

    related_content.map(&:child_relationable).reject do |related|
      related.respond_to?(:retired?) && related.retired?
    end
  end
end
