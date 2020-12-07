class Admin::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def item_title(section_name)
      link_to(t("admin.menu.title_#{section_name}"), "#", class: "#{section_name.tr("_", "-")}-link")
    end

    def booths_list
      link_list(
        officers_link,
        booths_link,
        booth_assignments_link,
        shifts_link,
        id: "booths_menu", class: ("is-active" if booths?)
      )
    end

    def messages_list
      link_list(
        newsletters_link,
        admin_notifications_link,
        system_emails_link,
        emails_download_link,
        id: "messaging_users_menu", class: ("is-active" if messages_menu_active?)
      )
    end

    def site_customization_list
      link_list(
        homepage_link,
        pages_link,
        banners_link,
        information_texts_link,
        documents_link,
        class: ("is-active" if customization? && controller.class.parent != Admin::Poll::Questions::Answers)
      )
    end

    def moderated_content_list
      link_list(
        (hidden_proposals_link if feature?(:proposals)),
        (hidden_debates_link if feature?(:debates)),
        (hidden_budget_investments_link if feature?(:budgets)),
        hidden_comments_link,
        hidden_proposal_notifications_link,
        hidden_users_link,
        activity_link,
        class: ("is-active" if moderated_content?)
      )
    end

    def profiles_list
      link_list(
        administrators_link,
        organizations_link,
        officials_link,
        moderators_link,
        valuators_link,
        managers_link,
        users_link,
        class: ("is-active" if profiles?)
      )
    end

    def settings_list
      link_list(
        settings_link,
        tags_link,
        geozones_link,
        images_link,
        content_blocks_link,
        local_census_records_link,
        class: ("is-active" if settings?)
      )
    end

    def dashboard_list
      link_list(
        dashboard_actions_link,
        dashboard_administrator_tasks_link,
        class: ("is-active" if dashboard?)
      )
    end

    def navigation_link(controller)
      [
        t("admin.menu.#{controller.tr("/", ".")}"),
        { controller: "/admin/#{controller}", action: :index },
        controller_name == controller.split("/").last,
        class: "#{controller.tr("_/", "-")}-link"
      ]
    end

    %w[
      proposals debates comments signature_sheets stats
      newsletters admin_notifications system_emails emails_download
      hidden_proposals hidden_debates hidden_budget_investments hidden_comments hidden_proposal_notifications hidden_users activity
      banners
      administrators organizations officials moderators valuators managers users
      settings tags geozones
    ].each do |controller|
      define_method :"#{controller}_link" do
        navigation_link(controller)
      end
    end

    %w[information_texts documents content_blocks].each do |controller|
      define_method :"#{controller}_link" do
        navigation_link("site_customization/#{controller}")
      end
    end

    %w[administrator_tasks actions].each do |controller|
      define_method :"dashboard_#{controller}_link" do
        navigation_link("dashboard/#{controller}")
      end
    end

    def polls_link
      [
        t("admin.menu.polls"),
        admin_polls_path,
        polls?,
        class: "polls-link"
      ]
    end

    def legislation_link
      [
        t("admin.menu.legislation"),
        admin_legislation_processes_path,
        controller.class.parent == Admin::Legislation,
        class: "legislation-link"
      ]
    end

    def budgets_link
      [
        t("admin.menu.budgets"),
        admin_budgets_path,
        budgets?,
        class: "budgets-link"
      ]
    end

    def officers_link
      [
        t("admin.menu.poll_officers"),
        admin_officers_path,
        %w[officers officer_assignments].include?(controller_name)
      ]
    end

    def booths_link
      [
        t("admin.menu.poll_booths"),
        admin_booths_path,
        controller_name == "booths" && action_name != "available"
      ]
    end

    def booth_assignments_link
      [
        t("admin.menu.poll_booth_assignments"),
        booth_assignments_admin_polls_path,
        controller_name == "polls" && action_name == "booth_assignments" || controller_name == "booth_assignments" && action_name == "manage"
      ]
    end

    def shifts_link
      [
        t("admin.menu.poll_shifts"),
        available_admin_booths_path,
        %w[shifts booths].include?(controller_name) && %w[available new].include?(action_name)
      ]
    end

    def homepage_link
      [
        t("admin.menu.site_customization.homepage"),
        admin_homepage_path,
        homepage?
      ]
    end

    def pages_link
      [
        t("admin.menu.site_customization.pages"),
        admin_site_customization_pages_path,
        pages? || controller_name == "pages"
      ]
    end

    def images_link
      [
        t("admin.menu.site_customization.images"),
        admin_site_customization_images_path,
        controller_name == "images" && controller.class.parent != Admin::Poll::Questions::Answers
      ]
    end

    def local_census_records_link
      [
        t("admin.menu.local_census_records"),
        admin_local_census_records_path,
        local_census_records?
      ]
    end

    def moderated_content?
      moderated_sections.include?(controller_name) && controller.class.parent != Admin::Legislation
    end

    def moderated_sections
      ["hidden_proposals", "hidden_debates", "hidden_comments", "hidden_users", "activity",
       "hidden_budget_investments", "hidden_proposal_notifications"]
    end

    def budgets?
      controller_name.starts_with?("budget")
    end

    def polls?
      controller.class.parent == Admin::Poll::Questions::Answers ||
        %w[polls active_polls recounts results questions answers].include?(controller_name) &&
        action_name != "booth_assignments"
    end

    def booths?
      %w[officers booths shifts booth_assignments officer_assignments].include?(controller_name) ||
        controller_name == "polls" && action_name == "booth_assignments"
    end

    def profiles?
      %w[administrators organizations officials moderators valuators managers users].include?(controller_name)
    end

    def settings?
      controllers_names = ["settings", "tags", "geozones", "images", "content_blocks",
                           "local_census_records", "imports"]
      controllers_names.include?(controller_name) &&
        controller.class.parent != Admin::Poll::Questions::Answers
    end

    def customization?
      ["pages", "banners", "information_texts", "documents"].include?(controller_name) ||
        homepage? || pages?
    end

    def homepage?
      ["homepage", "cards"].include?(controller_name) && params[:page_id].nil?
    end

    def pages?
      ["pages", "cards"].include?(controller_name) && params[:page_id].present?
    end

    def dashboard?
      ["actions", "administrator_tasks"].include?(controller_name)
    end

    def local_census_records?
      controller_name == "local_census_records" ||
        (controller_name == "imports" && controller.class.parent == Admin::LocalCensusRecords)
    end

    def messages_menu_active?
      messages_sections.include?(controller_name)
    end

    def messages_sections
      %w[newsletters emails_download admin_notifications system_emails]
    end
end
