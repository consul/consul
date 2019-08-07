class UserSegments
  def self.segments
    (regular_segments + geozones).to_h
  end

  def self.regular_segments
    %w[all_users
       administrators
       all_proposal_authors
       proposal_authors
       investment_authors
       feasible_and_undecided_investment_authors
       selected_investment_authors
       winner_investment_authors
       not_supported_on_current_budget].map do |name|
      [name, I18n.t("admin.segment_recipient.#{name}")]
    end
  end

  def self.segment_names
    segments.keys
  end

  def self.all_users
    User.active
  end

  def self.administrators
    all_users.administrators
  end

  def self.all_proposal_authors
    author_ids(Proposal.pluck(:author_id).uniq)
  end

  def self.proposal_authors
    author_ids(Proposal.not_archived.not_retired.pluck(:author_id).uniq)
  end

  def self.investment_authors
    author_ids(current_budget_investments.pluck(:author_id).uniq)
  end

  def self.feasible_and_undecided_investment_authors
    unfeasible_and_finished_condition = "feasibility = 'unfeasible' and valuation_finished = true"
    investments = current_budget_investments.where.not(unfeasible_and_finished_condition)
    author_ids(investments.pluck(:author_id).uniq)
  end

  def self.selected_investment_authors
    author_ids(current_budget_investments.selected.pluck(:author_id).uniq)
  end

  def self.winner_investment_authors
    author_ids(current_budget_investments.winners.pluck(:author_id).uniq)
  end

  def self.not_supported_on_current_budget
    author_ids(
      User.where(
                  "id NOT IN (SELECT DISTINCT(voter_id) FROM votes"\
                  " WHERE votable_type = ? AND votes.votable_id IN (?))",
                  "Budget::Investment",
                  current_budget_investments.pluck(:id)
                )
    )
  end

  def self.geozones
    if geozones_available?
      Geozone.all.map { |geozone| [geozone.name.parameterize.underscore, geozone.name] }.sort
    else
      []
    end
  end

  def self.geozones_available?
    ActiveRecord::Base.connection.data_source_exists?("geozones")
  end

  def self.generate_geozone_segments
    Geozone.all.each do |geozone|
      method_name = geozone.name.parameterize.underscore
      self.define_singleton_method(:"#{method_name}") do
        all_users.where(geozone: geozone)
      end
    end
  end

  if self.geozones_available?
    self.generate_geozone_segments
  end

  def self.user_segment_emails(users_segment)
    UserSegments.send(users_segment).newsletter.order(:created_at).pluck(:email).compact
  end

  private

  def self.current_budget_investments
    Budget.current.investments
  end

  def self.author_ids(author_ids)
    all_users.where(id: author_ids)
  end
end
