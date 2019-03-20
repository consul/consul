class Admin::DebatesController < Admin::BaseController
  include FeatureFlags
  include CommentableActions
  include HasOrders
  include Search
  feature_flag :debates

  has_orders %w[created_at]

  before_action :load_debate, only: [:confirm_hide, :restore]


  def show
    @debate = Debate.find(params[:id])
  end
  
  def index
    @debates = Debate.only_hidden
    @debates = @debates.search(@search_terms) if @search_terms.present?
    @debates = @debates.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @debate.confirm_hide
    redirect_to request.query_parameters.merge(action: :index)
  end

  def restore
    @debate.restore
    @debate.ignore_flag
    Activity.log(current_user, :restore, @debate)
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def resource_model
      Debate
    end
end
