class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  before_action :load_budget, only: :show
  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  before_action :load_geographies_data, only: :index
  has_filters %w[not_unfeasible feasible unfeasible unselected selected winners], only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, "Not Found" unless budget_published?(@budget)
  end

  def index
    @finished_budgets = @budgets.finished.order(created_at: :desc)
    @budgets_coordinates = current_budget_map_locations
    @banners = Banner.in_section("budgets").with_active
  end

  private

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:id]
    end

    def load_geographies_data
      @geographies_data = Geography.for_current_budget.map do |geography|
        {
          outline_points: geography.parsed_outline_points,
          color: geography.color,
          headings: geography.headings.map do |heading|
            helpers.link_to heading.name_with_budget,
                            budget_investments_path(heading.budget, params: { heading_id: heading.id })
          end
        }
      end
    end
end
