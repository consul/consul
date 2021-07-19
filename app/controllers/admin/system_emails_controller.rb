class Admin::SystemEmailsController < Admin::BaseController
  before_action :load_system_email, only: [:view, :preview_pending, :moderate_pending]

  def index
    @system_emails = {
      proposal_notification_digest: %w[view preview_pending],
      budget_investment_created:    %w[view edit_info],
      budget_investment_selected:   %w[view edit_info],
      budget_investment_unfeasible: %w[view edit_info],
      budget_investment_unselected: %w[view edit_info],
      comment:                      %w[view edit_info],
      reply:                        %w[view edit_info],
      direct_message_for_receiver:  %w[view edit_info],
      direct_message_for_sender:    %w[view edit_info],
      email_verification:           %w[view edit_info],
      user_invite:                  %w[view edit_info],
      evaluation_comment:           %w[view edit_info]
    }
  end

  def view
    case @system_email
    when "proposal_notification_digest"
      load_sample_proposal_notifications
    when /\Abudget_investment/
      load_sample_investment
    when /\Adirect_message/
      load_sample_direct_message
    when "comment"
      load_sample_comment
    when "reply"
      load_sample_reply
    when "email_verification"
      load_sample_user
    when "user_invite"
      @subject = t("mailers.user_invite.subject", org_name: Setting["org_name"])
    when "evaluation_comment"
      load_sample_valuation_comment
    end
  end

  def preview_pending
    case @system_email
    when "proposal_notification_digest"
      @previews = ProposalNotification.where(id: unsent_proposal_notifications_ids)
                                      .page(params[:page])
    end
  end

  def moderate_pending
    ProposalNotification.find(params[:id]).moderate_system_email(current_user)

    redirect_to admin_system_email_preview_pending_path("proposal_notification_digest")
  end

  def send_pending
    Notification.delay.send_pending

    flash[:notice] = t("admin.system_emails.preview_pending.send_pending_notification")
    redirect_to admin_system_emails_path
  end

  private

    def load_system_email
      @system_email = params[:system_email_id]
    end

    def load_sample_proposal_notifications
      @receiver = current_user
      @notifications = Notification.where(notifiable_type: "ProposalNotification").limit(2)
      @subject = t("mailers.proposal_notification_digest.title", org_name: Setting["org_name"])
    end

    def load_sample_investment
      if Budget::Investment.any?
        @investment = Budget::Investment.last
        @subject = t("mailers.#{@system_email}.subject", code: @investment.code)
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_investments")
      end
    end

    def load_sample_comment
      @comment = Comment.where(commentable_type: %w[Debate Proposal Budget::Investment]).last
      if @comment
        @commentable = @comment.commentable
        @receiver = @commentable.author
        @subject = t("mailers.comment.subject", commentable: commentable_name)
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_comments")
      end
    end

    def load_sample_reply
      reply = Comment.select(&:reply?).last
      if reply
        @email = ReplyEmail.new(reply)
        @receiver = @email.recipient
      else
        redirect_to admin_system_emails_path, alert: t("admin.system_emails.alert.no_replies")
      end
    end

    def load_sample_valuation_comment
      comment = Comment.where(commentable_type: "Budget::Investment").last
      if comment
        @email = EvaluationCommentEmail.new(comment)
        @email_to = @email.to.first
      else
        redirect_to admin_system_emails_path,
                    alert: t("admin.system_emails.alert.no_evaluation_comments")
      end
    end

    def load_sample_user
      @user = User.last
      @token = @user.email_verification_token || SecureRandom.hex
      @subject = t("mailers.email_verification.subject")
    end

    def load_sample_direct_message
      @direct_message = DirectMessage.new(sender: current_user, receiver: current_user,
                                          title: t("admin.system_emails.message_title"),
                                          body: t("admin.system_emails.message_body"))
      @receiver = @direct_message.receiver
      @subject = t("mailers.#{@system_email}.subject")
    end

    def commentable_name
      t("activerecord.models.#{@commentable.class.name.underscore}", count: 1)
    end

    def unsent_proposal_notifications_ids
      Notification.where(notifiable_type: "ProposalNotification", emailed_at: nil)
                  .group(:notifiable_id).count.keys
    end
end
