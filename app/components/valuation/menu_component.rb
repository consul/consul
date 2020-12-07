class Valuation::MenuComponent < ApplicationComponent
  include LinkListHelper

  private

    def valuation_link
      [t("valuation.menu.title"), valuation_root_path]
    end

    def budgets_link
      [
        t("valuation.menu.budgets"),
        valuation_budgets_path,
        controller_name == "budget_investments",
        class: "budgets-link"
      ]
    end
end
