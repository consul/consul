# frozen_string_literal: true

module HasPhases
  extend ActiveSupport::Concern

  included do
    scope :recent, -> { order(id: :desc) }
    class_variable_set :@@phases_info, {}
  end

  class_methods do
    def has_phase(*phases, **opts)
      phases_info = class_variable_get :@@phases_info

      # ignore attributes options if more than one phase is set
      opts = opts.except(:start_date, :end_date, :phase_enabled) if phases.count > 1

      phase_keyword = opts[:phase_keyword] || :phase

      phases.each do |phase|
        sym = Utils.symbol_with_prefix(phase)

        method_sym = sym.call(phase_keyword)
        cols = Utils.get_phase_columns(opts, sym)

        phases_info[method_sym] = cols

        define_method method_sym do
          Phase.new(cols.transform_values { |column| send(column) })
        end

        # validations
        if cols.key? :end_date
          validate do
            errors.add(cols[:end_date], :invalid_date_range) unless send(method_sym).valid?
          end

          validates cols[:start_date], presence: true
          validates cols[:end_date], presence: true
        end

        # scopes
        scope sym.call('published'), -> { where(cols[:phase_enabled] => true) }
        scope sym.call('next'), -> { recent.where("#{cols[:start_date]} > ?", Date.current) }
        scope sym.call('started'), -> { recent.where("#{cols[:start_date]} <= ?", Date.current) }

        if cols.key? :end_date
          scope sym.call('open'), -> { recent.send(sym.call('started')).where("#{cols[:end_date]} >= ?", Date.current) }
          scope sym.call('past'), -> { recent.where("#{cols[:end_date]} < ?", Date.current) }
        end
      end

      define_singleton_method :phases_info do
        phases_info
      end

      define_method :enabled_phases_and_publications_count do
        phases_info.keys.count { |phase| send(phase).enabled? }
      end

      class_variable_set :@@phases_info, phases_info
    end
  end

end
