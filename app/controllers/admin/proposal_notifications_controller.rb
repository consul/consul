class Admin::ProposalNotificationsController < Admin::BaseController
  include Search

  has_filters %w[without_confirmed_hide all with_confirmed_hide], only: :index

  before_action :load_proposal, only: [:confirm_hide, :restore]

  def index
    @proposal_notifications = ProposalNotification.only_hidden
    @proposal_notifications = @proposal_notifications.search(@search_terms) if @search_terms.present?
    @proposal_notifications = @proposal_notifications.send(@current_filter)
                                                     .order(hidden_at: :desc)
                                                     .page(params[:page])
  end

  def confirm_hide
    @proposal_notification.confirm_hide
    redirect_with_query_params_to(action: :index)
  end

  def restore
    @proposal_notification.restore
    @proposal_notification.ignore_flag
    Activity.log(current_user, :restore, @proposal_notification)
    redirect_with_query_params_to(action: :index)
  end

  private

    def load_proposal
      @proposal_notification = ProposalNotification.with_hidden.find(params[:id])
    end
end
