class Moderation::UsersController < Moderation::BaseController
  before_action :load_users, only: :index

  load_and_authorize_resource

  def index
  end

  def hide_in_moderation_screen
    block_user

    redirect_with_query_params_to({ action: :index }, { notice: I18n.t("moderation.users.notice_hide") })
  end

  def soft_block
    @user.hide
    Activity.log(current_user, :soft_block, @user)

    redirect_with_query_params_to({ action: :index }, { notice: I18n.t("moderation.users.notice_soft_hide") })
  end

  def hide
    block_user

    redirect_to debates_path
  end

  private

    def load_users
      @users = User.with_hidden.search(params[:name_or_email]).page(params[:page]).for_render
    end

    def block_user
      @user.block
      Activity.log(current_user, :block, @user)
    end
end
