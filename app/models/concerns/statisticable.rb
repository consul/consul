module Statisticable
  extend ActiveSupport::Concern
  PARTICIPATIONS = %w[gender age geozone].freeze

  included do
    attr_reader :resource
  end

  class_methods do
    def stats_methods
      base_stats_methods + gender_methods + age_methods + geozone_methods
    end

    def base_stats_methods
      %i[total_participants participations] + participation_check_methods
    end

    def participation_check_methods
      PARTICIPATIONS.map { |participation| :"#{participation}?" }
    end

    def gender_methods
      %i[total_male_participants total_female_participants male_percentage
        female_percentage total_other_participants other_percentage]
    end

    def age_methods
      [:participants_by_age]
    end

    def geozone_methods
      %i[participants_by_geozone total_no_demographic_data]
    end

    def stats_cache(*method_names)
      method_names.each do |method_name|
        alias_method :"raw_#{method_name}", method_name

        define_method method_name do
          stats_cache(method_name) { send(:"raw_#{method_name}") }
        end
      end
    end
  end

  def initialize(resource)
    @resource = resource
  end

  def generate
    stats_methods.each { |stat_name| send(stat_name) }
  end

  def stats_methods
    base_stats_methods + participation_methods
  end

  def participations
    PARTICIPATIONS.select { |participation| send("#{participation}?") }
  end

  def gender?
    participants.male.any? || participants.female.any? || participants.other.any?
  end

  def age?
    participants.between_ages(age_groups.flatten.min, age_groups.flatten.max).any?
  end

  def geozone?
    participants.where(geozone: geozones).any?
  end

  def participants
    @participants ||= User.unscoped.where(id: participant_ids)
  end

  def total_male_participants
    participants.male.count
  end

  def total_female_participants
    participants.female.count
  end

  def total_other_participants
    participants.other.count
  end

  def total_no_demographic_data
    participants.where("gender IS NULL OR date_of_birth IS NULL OR geozone_id IS NULL").count
  end

  def male_percentage
    calculate_percentage(total_male_participants, total_participants_with_gender)
  end

  def female_percentage
    calculate_percentage(total_female_participants, total_participants_with_gender)
  end

  def other_percentage
    calculate_percentage(total_other_participants, total_participants_with_gender)
  end

  def participants_by_age
    age_groups.map do |start, finish|
      count = participants.between_ages(start, finish).count

      [
        "#{start} - #{finish}",
        {
          range: range_description(start, finish),
          count: count,
          percentage: calculate_percentage(count, total_participants)
        }
      ]
    end.to_h
  end

  def participants_by_geozone
    geozone_stats.map do |stats|
      [
        stats.name,
        {
          count: stats.count,
          percentage: stats.percentage
        }
      ]
    end.to_h
  end

  def calculate_percentage(fraction, total)
    PercentageCalculator.calculate(fraction, total)
  end

  def version
    "v#{resource.find_or_create_stats_version.updated_at.to_i}"
  end

  def advanced?
    resource.advanced_stats_enabled?
  end

  private

    def base_stats_methods
      self.class.base_stats_methods
    end

    def participation_methods
      participations.map { |participation| self.class.send("#{participation}_methods") }.flatten
    end

    def total_participants_with_gender
      @total_participants_with_gender ||= participants.where.not(gender: nil).distinct.count
    end

    def age_groups
      [[16, 19],
       [20, 24],
       [25, 29],
       [30, 34],
       [35, 39],
       [40, 44],
       [45, 49],
       [50, 54],
       [55, 59],
       [60, 64],
       [65, 69],
       [70, 74],
       [75, 79],
       [80, 84],
       [85, 89],
       [90, 300]
      ]
    end

    def participants_between_ages(from, to)
      participants.between_ages(from, to)
    end

    def geozones
      Geozone.all.order("name")
    end

    def geozone_stats
      geozones.map { |geozone| GeozoneStats.new(geozone, participants) }
    end

    def range_description(start, finish)
      if finish > 200
        I18n.t("stats.age_more_than", start: start)
      else
        I18n.t("stats.age_range", start: start, finish: finish)
      end
    end
end
