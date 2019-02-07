class GeojsonFormat < ActiveModel::Validator

  def validate(record)
    if not record.geojson.blank?
      geojson_data_hash = parse_json(record.geojson)

      if not geojson_data_hash or geojson_data_hash.class != Hash or
      not validate_geojson_format(geojson_data_hash)
        record.errors.add(:base, 'The GeoJSON provided does not follow the correct format.
                                  It must follow the "Polygon" or "MultiPolygon" type format.')
      end
    end
  end

  private

  def parse_json(geojson_data)
    JSON.parse(geojson_data) rescue nil
  end

  def validate_geojson_format(geojson_data_hash)
    geojson_data_hash.key?("geometry") &&
    geojson_data_hash["geometry"].key?("coordinates") &&
    geojson_data_hash["geometry"]["coordinates"].class == Array
  end

end
