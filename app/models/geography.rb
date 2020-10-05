class Geography < ApplicationRecord
  validates :name, presence: true
  validates :color, presence: true
  validates_with GeojsonFormat

  has_many :headings, class_name: Budget::Heading, dependent: :nullify

  def self.for_current_budget
    if Budget.current.present?
      Budget.current.headings.select { |heading| heading.geography.present? }.map(&:geography)
    else
      []
    end
  end

  def parsed_outline_points
    if geojson.present?
      coordinates_array = JSON.parse(geojson)["geometry"]["coordinates"]

      if geojson.match(/"coordinates"\s*:\s*\[{4}/)
        coordinates_array = coordinates_array.reduce([], :concat).reduce([], :concat)
      elsif geojson.match(/"coordinates"\s*:\s*\[{3}/)
        coordinates_array = coordinates_array.reduce([], :concat)
      end

      coordinates_array.map { |coordinates| [coordinates.second, coordinates.first] }
    else
      []
    end
  end
end
