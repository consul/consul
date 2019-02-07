FactoryBot.define do
  factory :spending_proposal do
    sequence(:title)     { |n| "Spending Proposal #{n} title" }
    description          'Spend money on this'
    feasible_explanation 'This proposal is not viable because...'
    external_url         'http://external_documention.org'
    terms_of_service     '1'
    association :author, factory: :user
  end

  factory :budget do
    sequence(:name) { |n| "#{Faker::Lorem.word} #{n}" }
    currency_symbol "€"
    phase 'accepting'
    description_drafting  "This budget is drafting"
    description_informing "This budget is informing"
    description_accepting "This budget is accepting"
    description_reviewing "This budget is reviewing"
    description_selecting "This budget is selecting"
    description_valuating "This budget is valuating"
    description_publishing_prices "This budget is publishing prices"
    description_balloting "This budget is balloting"
    description_reviewing_ballots "This budget is reviewing ballots"
    description_finished "This budget is finished"

    trait :drafting do
      phase 'drafting'
    end

    trait :informing do
      phase 'informing'
    end

    trait :accepting do
      phase 'accepting'
    end

    trait :reviewing do
      phase 'reviewing'
    end

    trait :selecting do
      phase 'selecting'
    end

    trait :valuating do
      phase 'valuating'
    end

    trait :publishing_prices do
      phase 'publishing_prices'
    end

    trait :balloting do
      phase 'balloting'
    end

    trait :reviewing_ballots do
      phase 'reviewing_ballots'
    end

    trait :finished do
      phase 'finished'
    end
  end

  factory :budget_group, class: 'Budget::Group' do
    budget
    sequence(:name) { |n| "Group #{n}" }

    trait :drafting_budget do
      association :budget, factory: [:budget, :drafting]
    end

    trait :accepting_budget do
      association :budget, factory: [:budget, :accepting]
    end
  end

  factory :budget_heading, class: 'Budget::Heading' do
    association :group, factory: :budget_group
    sequence(:name) { |n| "Heading #{n}" }
    price 1000000
    population 1234
    latitude '40.416775'
    longitude '-3.703790'

    trait :drafting_budget do
      association :group, factory: [:budget_group, :drafting_budget]
    end

    trait :accepting_budget do
      association :group, factory: [:budget_group, :accepting_budget]
    end
  end

  factory :budget_investment, class: 'Budget::Investment' do
    sequence(:title) { |n| "Budget Investment #{n} title" }
    association :heading, factory: :budget_heading
    association :author, factory: :user
    description          'Spend money on this'
    price                10
    unfeasibility_explanation ''
    skip_map             '1'
    terms_of_service     '1'
    incompatible          false

    trait :with_confidence_score do
      before(:save) { |i| i.calculate_confidence_score }
    end

    trait :feasible do
      feasibility "feasible"
    end

    trait :unfeasible do
      feasibility "unfeasible"
      unfeasibility_explanation "set to unfeasible on creation"
    end

    trait :undecided do
      feasibility "undecided"
    end

    trait :finished do
      valuation_finished true
    end

    trait :selected do
      selected true
      feasibility "feasible"
      valuation_finished true
    end

    trait :winner do
      selected
      winner true
    end

    trait :visible_to_valuators do
      visible_to_valuators true
    end

    trait :incompatible do
      selected
      incompatible true
    end

    trait :selected_with_price do
      selected
      price 1000
      price_explanation 'Because of reasons'
    end

    trait :unselected do
      selected false
      feasibility "feasible"
      valuation_finished true
    end

     trait :hidden do
       hidden_at { Time.current }
     end

     trait :with_ignored_flag do
       ignored_flag_at { Time.current }
     end

    trait :flagged do
       after :create do |investment|
         Flag.flag(create(:user), investment)
       end
     end

     trait :with_confirmed_hide do
       confirmed_hide_at { Time.current }
     end
  end

  factory :budget_phase, class: 'Budget::Phase' do
    budget
    kind        :balloting
    summary     Faker::Lorem.sentence(3)
    description Faker::Lorem.sentence(10)
    starts_at   { Date.yesterday }
    ends_at     { Date.tomorrow }
    enabled     true
  end

  factory :budget_ballot, class: 'Budget::Ballot' do
    association :user, factory: :user
    budget
  end

  factory :budget_ballot_line, class: 'Budget::Ballot::Line' do
    association :ballot, factory: :budget_ballot
    association :investment, factory: :budget_investment
  end

  factory :budget_reclassified_vote, class: 'Budget::ReclassifiedVote' do
    user
    association :investment, factory: :budget_investment
    reason "unfeasible"
  end

  factory :valuator_group, class: ValuatorGroup do
    sequence(:name) { |n| "Valuator Group #{n}" }
  end

  factory :heading_content_block, class: 'Budget::ContentBlock' do
    association :heading, factory: :budget_heading
    locale 'en'
    body 'Some heading contents'
  end
end
