class UnsubscribesController < ApplicationController
  before_action :set_user
  skip_authorization_check

  def edit
  end

  def update
    @user.update!(unsubscribe_params)
    redirect_to edit_unsubscribe_path, notice: t("flash.actions.save_changes.notice")
  end

  private

    def set_user
      @user = User.find_by(unsubscribe_hash: params[:unsubscribe_hash])
    end

    def unsubscribe_params
      attributes = [:email_on_comment, :email_on_comment_reply, :email_on_direct_message,
                    :email_digest, :newsletter]
      params.require(:user).permit(*attributes)
    end
end
