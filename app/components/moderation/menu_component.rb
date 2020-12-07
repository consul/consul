class Moderation::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def moderation_link
      [t("moderation.dashboard.index.title"), moderation_root_path]
    end

    def proposals_link
      [
        t("moderation.menu.proposals"),
        moderation_proposals_path,
        controller_name == "proposals",
        class: "proposals-link"
      ]
    end

    def proposal_notifications_link
      [
        t("moderation.menu.proposal_notifications"),
        moderation_proposal_notifications_path,
        controller_name == "proposal_notifications",
        class: "proposal-notifications-link"
      ]
    end

    def debates_link
      [
        t("moderation.menu.flagged_debates"),
        moderation_debates_path,
        controller_name == "debates",
        class: "debates-link"
      ]
    end

    def investments_link
      [
        t("moderation.menu.flagged_investments"),
        moderation_budget_investments_path,
        controller_name == "investments",
        class: "investments-link"
      ]
    end

    def comments_link
      [
        t("moderation.menu.flagged_comments"),
        moderation_comments_path,
        controller_name == "comments",
        class: "comments-link"
      ]
    end

    def users_link
      [
        t("moderation.menu.users"),
        moderation_users_path,
        controller_name == "users",
        class: "users-link"
      ]
    end
end
