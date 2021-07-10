INVESTMENT_IMAGE_FILES = %w[
  brennan-ehrhardt-25066-unsplash_713x513.jpg
  carl-nenzen-loven-381554-unsplash_713x475.jpg
  carlos-zurita-215387-unsplash_713x475.jpg
  hector-arguello-canals-79584-unsplash_713x475.jpg
  olesya-grichina-218176-unsplash_713x475.jpg
  sole-d-alessandro-340443-unsplash_713x475.jpg
].map do |filename|
  File.new(Rails.root.join("db",
                           "dev_seeds",
                           "images",
                           "budget",
                           "investments", filename))
end

def add_image_to(imageable)
  # imageable should respond to #title & #author
  imageable.image = Image.create!({
    imageable: imageable,
    title: imageable.title,
    attachment: INVESTMENT_IMAGE_FILES.sample,
    user: imageable.author
  })
  imageable.save!
end

section "Creating Budgets" do
  locale_1 = I18n.available_locales.first
  locale_2 = I18n.available_locales.second

  Budget.create!(
    "name_#{locale_1}": "#{I18n.t("seeds.budgets.budget", locale: locale_1)} #{Date.current.year - 1}",
    "name_#{locale_2}": "#{I18n.t("seeds.budgets.budget", locale: locale_2)} #{Date.current.year - 1}",
    currency_symbol: I18n.t("seeds.budgets.currency"),
    phase: "finished",
    published: true
  )

  Budget.create!(
    "name_#{locale_1}": "#{I18n.t("seeds.budgets.budget", locale: locale_1)} #{Date.current.year}",
    "name_#{locale_2}": "#{I18n.t("seeds.budgets.budget", locale: locale_2)} #{Date.current.year}",
    currency_symbol: I18n.t("seeds.budgets.currency"),
    phase: "accepting",
    published: true
  )

  Budget.find_each do |budget|
    budget.phases.each do |phase|
      random_locales.map do |locale|
        Globalize.with_locale(locale) do
          phase.name = "Name for locale #{locale}"
          phase.description = "Description for locale #{locale}"
          phase.summary = "Summary for locale #{locale}"
          phase.save!
        end
      end
    end
  end

  Budget.all.each do |budget|
    city_group_params = {
      "name_#{locale_1}": I18n.t("seeds.budgets.groups.all_city", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.budgets.groups.all_city", locale: locale_2)
    }
    city_group = budget.groups.create!(city_group_params)

    city_heading_params = {
      "name_#{locale_1}": I18n.t("seeds.budgets.groups.all_city", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.budgets.groups.all_city", locale: locale_2),
      price: 1000000,
      population: 1000000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    city_group.headings.create!(city_heading_params)

    districts_group_params = {
      "name_#{locale_1}": I18n.t("seeds.budgets.groups.districts", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.budgets.groups.districts", locale: locale_2)
    }
    districts_group = budget.groups.create!(districts_group_params)

    north_heading_params = {
      "name_#{locale_1}": I18n.t("seeds.geozones.north_district", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.geozones.north_district", locale: locale_2),
      price: rand(5..10) * 100000,
      population: 350000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(north_heading_params)

    west_heading_params = {
      "name_#{locale_1}": I18n.t("seeds.geozones.west_district", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.geozones.west_district", locale: locale_2),
      price: rand(5..10) * 100000,
      population: 300000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(west_heading_params)

    east_heading_params = {
      "name_#{locale_1}": I18n.t("seeds.geozones.east_district", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.geozones.east_district", locale: locale_2),
      price: rand(5..10) * 100000,
      population: 200000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(east_heading_params)

    central_heading_params = {
      "name_#{locale_1}": I18n.t("seeds.geozones.central_district", locale: locale_1),
      "name_#{locale_2}": I18n.t("seeds.geozones.central_district", locale: locale_2),
      price: rand(5..10) * 100000,
      population: 150000,
      latitude: "40.416775",
      longitude: "-3.703790"
    }
    districts_group.headings.create!(central_heading_params)
  end
end

section "Creating Investments" do
  tags = Faker::Lorem.words(10)
  100.times do
    heading = Budget::Heading.all.sample

    translation_attributes = random_locales.each_with_object({}) do |locale, attributes|
      attributes["title_#{locale.to_s.underscore}"] = "Title for locale #{locale}"
      attributes["description_#{locale.to_s.underscore}"] = "<p>Description for locale #{locale}</p>"
    end

    investment = Budget::Investment.create!({
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: %w[undecided unfeasible feasible feasible feasible feasible].sample,
      unfeasibility_explanation: Faker::Lorem.paragraph,
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(","),
      price: rand(1..100) * 100000,
      terms_of_service: "1"
    }.merge(translation_attributes))

    add_image_to(investment) if Random.rand > 0.5
  end
end

section "Marking investments as visible to valuators" do
  (1..50).to_a.sample.times do
    Budget::Investment.sample.update(visible_to_valuators: true)
  end
end

section "Geolocating Investments" do
  Budget.find_each do |budget|
    budget.investments.each do |investment|
      MapLocation.create(latitude: Setting["map.latitude"].to_f + rand(-10..10) / 100.to_f,
                         longitude: Setting["map.longitude"].to_f + rand(-10..10) / 100.to_f,
                         zoom: Setting["map.zoom"],
                         investment_id: investment.id)
    end
  end
end

section "Balloting Investments" do
  Budget.finished.first.investments.last(20).each do |investment|
    investment.update(selected: true, feasibility: "feasible")
  end
end

section "Winner Investments" do
  budget = Budget.finished.first
  50.times do
    heading = budget.headings.all.sample
    investment = Budget::Investment.create!(
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      description: "<p>#{Faker::Lorem.paragraphs.join("</p><p>")}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: "feasible",
      valuation_finished: true,
      selected: true,
      price: rand(10000..heading.price),
      terms_of_service: "1"
    )
    add_image_to(investment) if Random.rand > 0.3
  end
  budget.headings.each do |heading|
    Budget::Result.new(budget, heading).calculate_winners
  end
end

section "Creating Valuation Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuators << Valuator.first
  end
end
