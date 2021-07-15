class TagCloud
  attr_accessor :resource_model, :scope

  def initialize(resource_model, scope = nil)
    @resource_model = resource_model
    @scope = scope
  end

  def tags
    resource_model_scoped.
    last_week.send(counts).
    where("lower(name) NOT IN (?)", category_names + geozone_names + default_blacklist).
    order("#{table_name}_count": :desc, name: :asc).
    limit(10)
  end

  def counts
    return :tag_counts unless Setting["machine_learning.tags"]
    return :ml_proposal_tag_counts if self.is_a? Proposal
    return :ml_investment_tag_counts if self.is_a? Budget::Investment

    :tag_counts
  end

  def category_names
    Tag.category_names.map(&:downcase)
  end

  def geozone_names
    Geozone.all.map { |geozone| geozone.name.downcase }
  end

  def resource_model_scoped
    scope && resource_model == Proposal ? resource_model.search(scope) : resource_model
  end

  def default_blacklist
    [""]
  end

  def table_name
    resource_model.to_s.tableize.tr("/", "_")
  end
end
