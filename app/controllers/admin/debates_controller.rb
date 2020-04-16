class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders

  feature_flag :debates

  has_orders %w[created_at]

  def show
    @debate = Debate.find(params[:id])
  end

  private

    def resource_model
      Debate
    end
end
