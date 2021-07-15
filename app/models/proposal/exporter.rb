class Proposal::Exporter
  def to_json_file(filename)
    proposals = []
    Proposal.find_each do |proposal|
      proposals << json_values(proposal)
    end
    File.open(filename, "w") do |file|
      file.write(proposals.to_json)
    end
  end

  private

    def json_values(proposal)
      {
        id: proposal.id,
        title: proposal.title,
        summary: strip_tags(proposal.summary),
        description: strip_tags(proposal.description)
      }
    end

    def strip_tags(html_string)
      ActionView::Base.full_sanitizer.sanitize(html_string)
    end
end
