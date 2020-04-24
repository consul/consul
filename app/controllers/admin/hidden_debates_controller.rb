class Admin::HiddenDebatesController < Admin::BaseController
  include FeatureFlags
  include Search

  feature_flag :debates

  has_filters %w[without_confirmed_hide all with_confirmed_hide], only: :index

  before_action :load_debate, only: [:confirm_hide, :restore]

  def index
    @debates = Debate.only_hidden
    @debates = @debates.search(@search_terms) if @search_terms.present?
    @debates = @debates.send(@current_filter).order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @debate.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @debate.restore!(recursive: true)
    @debate.ignore_flag
    Activity.log(current_user, :restore, @debate)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_debate
      @debate = Debate.with_hidden.find(params[:id])
    end
end
