class CensusCaller
  def call(document_type, document_number, date_of_birth, postal_code, tenant = Tenant.current)
    if Setting["feature.remote_census"].present?
      response = RemoteCensusApi.new.call(document_type, document_number, date_of_birth, postal_code)
    else
      response = CensusApi.new.call(document_type, document_number)
    end
    response = LocalCensus.new.call(document_type, document_number) unless response.valid?

    response
  end
end
