class Admin::ActivityController < Admin::BaseController
  has_filters %w[all on_users on_proposals on_debates on_comments on_system_emails]

  def index
    @activity = Activity.for_render.send(@current_filter)
                        .order(created_at: :desc).page(params[:page])
  end
end
