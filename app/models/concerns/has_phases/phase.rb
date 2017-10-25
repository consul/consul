# frozen_string_literal: true

module HasPhases
  class Phase

    def initialize(start_date:, phase_enabled:, end_date: nil)
      @start_date = start_date
      @end_date = end_date
      @enabled = phase_enabled
    end

    def valid?
      !@end_date || !@start_date || @start_date <= @end_date
    end

    def enabled?
      @enabled
    end

    def end_date?
      @end_date.present?
    end

    def started?
      enabled? && Date.current >= @start_date
    end

    def open?
      started? && (!end_date? || Date.current <= @end_date)
    end

    def status
      today = Date.current

      if today < @start_date
        :planned
      elsif end_date? && @end_date < today
        :closed
      else
        :open
      end
    end

  end
end
