module Mappable
  extend ActiveSupport::Concern

  included do
    attribute :skip_map, :boolean

    has_one :map_location, dependent: :destroy
    accepts_nested_attributes_for :map_location, allow_destroy: true, reject_if: :all_blank

    validates :skip_map, presence: {
      on:      :create,
      if:      -> { Setting["feature.map"].present? },
      unless:  -> { map_location&.available? },
      message: I18n.t("activerecord.errors.models.map_location.attributes.map.invalid")
    }
  end
end
