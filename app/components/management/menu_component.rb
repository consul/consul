class Management::MenuComponent < ApplicationComponent
  include LinkListHelper
  delegate :managed_user, to: :helpers

  private

    def item_title(section_name)
      link_to(t("management.menu.#{section_name}"), "#", class: "#{section_name.tr("_", "-")}-link")
    end

    def users_list
      link_list(
        document_verifications_link,
        (edit_password_email_link if managed_user.email),
        edit_password_manually_link,
        new_proposal_link,
        proposals_link,
        (create_investments_link if Setting["process.budgets"]),
        (support_investments_link if Setting["process.budgets"]),
        class: "is-active"
      )
    end

    def document_verifications_link
      [
        t("management.menu.select_user"),
        management_document_verifications_path,
        users?
      ]
    end

    def edit_password_email_link
      [
        t("management.account.menu.reset_password_email"),
        edit_password_email_management_account_path,
        edit_password_email?
      ]
    end

    def edit_password_manually_link
      [
        t("management.account.menu.reset_password_manually"),
        edit_password_manually_management_account_path,
        edit_password_manually?
      ]
    end

    def new_proposal_link
      [
        t("management.menu.create_proposal"),
        new_management_proposal_path,
        create_proposal?
      ]
    end

    def proposals_link
      [
        t("management.menu.support_proposals"),
        management_proposals_path,
        support_proposal?
      ]
    end

    def create_investments_link
      [
        t("management.menu.create_budget_investment"),
        create_investments_management_budgets_path,
        create_investments?
      ]
    end

    def support_investments_link
      [
        t("management.menu.support_budget_investments"),
        support_investments_management_budgets_path,
        support_investments?
      ]
    end

    def print_investments_link
      [
        t("management.menu.print_budget_investments"),
        print_investments_management_budgets_path,
        print_investments?,
        class: "print-investments-link"
      ]
    end

    def print_proposals_link
      [
        t("management.menu.print_proposals"),
        print_management_proposals_path,
        print_proposals?,
        class: "print-proposals-link"
      ]
    end

    def user_invites_link
      [
        t("management.menu.user_invites"),
        new_management_user_invite_path,
        user_invites?,
        class: "invitations-link"
      ]
    end

    def users?
      ["users", "email_verifications", "document_verifications"].include?(controller_name)
    end

    def edit_password_email?
      controller_name == "account" && action_name == "edit_password_email"
    end

    def edit_password_manually?
      controller_name == "account" && action_name == "edit_password_manually"
    end

    def create_proposal?
      controller_name == "proposals" && action_name == "new"
    end

    def support_proposal?
      controller_name == "proposals" && action_name == "index"
    end

    def print_proposals?
      controller_name == "proposals" && action_name == "print"
    end

    def create_investments?
      (controller_name == "budget_investments" && action_name == "new") ||
        (controller_name == "budgets" && action_name == "create_investments")
    end

    def support_investments?
      (controller_name == "budget_investments" && action_name == "index") ||
        (controller_name == "budgets" && action_name == "support_investments")
    end

    def print_investments?
      (controller_name == "budget_investments" && action_name == "print") ||
        (controller_name == "budgets" && action_name == "print_investments")
    end

    def user_invites?
      controller_name == "user_invites"
    end
end
