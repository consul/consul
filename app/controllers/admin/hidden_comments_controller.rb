class Admin::HiddenCommentsController < Admin::BaseController
  include Search

  has_filters %w[without_confirmed_hide all with_confirmed_hide]

  before_action :load_comment, only: [:confirm_hide, :restore]

  def index
    @comments = Comment.not_valuations.only_hidden
    @comments = @comments.search(@search_terms) if @search_terms.present?
    @comments = @comments.with_visible_author.send(@current_filter)
                         .order(hidden_at: :desc).page(params[:page])
  end

  def confirm_hide
    @comment.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @comment.restore(recursive: true)
    @comment.ignore_flag
    Activity.log(current_user, :restore, @comment)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_comment
      @comment = Comment.not_valuations.with_hidden.find(params[:id])
    end
end
