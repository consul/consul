class SDGManagement::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def goals_link
      [
        t("sdg_management.menu.sdg_content"),
        sdg_management_goals_path,
        sdg?,
        class: "goals-link"
      ]
    end

    def sdg?
      controller_name == "goals" || controller_name == "targets"
    end
end
