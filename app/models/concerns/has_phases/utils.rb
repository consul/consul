# frozen_string_literal: true

module HasPhases
  module Utils
    PHASE_ATTRIBUTES = { publication: [:start_date, :phase_enabled],
                         default: [:start_date, :end_date, :phase_enabled] }.freeze

    def self.get_phase_columns(options, symbol_builder)
      attributes = if options[:publication]
                     PHASE_ATTRIBUTES[:publication]
                   else
                     PHASE_ATTRIBUTES[:default]
                   end
      attributes.inject({}) do |hash, attribute|
        hash.merge(attribute => options[attribute] || symbol_builder.call(attribute))
      end
    end

    def self.symbol_with_prefix(prefix)
      ->(string) { :"#{prefix}_#{string}" }
    end
  end
end
