class GeojsonFormat < ActiveModel::Validator
  def validate(record)
    if record.geojson.present?
      geojson = parse_json(record.geojson)
      unless valid_format?(geojson)
        record.errors.add(:geojson, I18n.t("admin.geographies.form.invalid_format"))
      end
    end
  end

  private

    def parse_json(geojson_data)
      JSON.parse(geojson_data) rescue nil
    end

    def valid_format?(geojson)
      return false unless geojson.is_a? Hash
      return false unless geojson["geometry"].present?
      return false unless geojson["geometry"]["coordinates"].present?

      geojson["geometry"]["coordinates"].is_a? Array
    end
end
