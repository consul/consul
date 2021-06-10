module Measurable
  extend ActiveSupport::Concern

  class_methods do
    def title_max_length
      @title_max_length ||= (columns.find { |c| c.name == "title" }&.limit) || 80
    end

    def responsible_name_max_length
      @responsible_name_max_length ||= (columns.find { |c| c.name == "responsible_name" }&.limit) || 60
    end

    def question_max_length
      140
    end

    def description_min_length
      10
    end

    def description_max_length
      6000
    end
  end
end
