FactoryBot.define do
  factory :tag do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :category do
      kind { "category" }
    end

    trait :milestone do
      kind { "milestone" }
    end

    transient { taggables { [] } }

    after(:create) do |tag, evaluator|
      evaluator.taggables.each do |taggable|
        create(:tagging, tag: tag, taggable: taggable)
      end
    end
  end

  factory :tagging do
    context { "tags" }
    association :taggable, factory: :proposal
    tag
  end

  factory :topic do
    sequence(:title) { |n| "Topic title #{n}" }
    sequence(:description) { |n| "Description as comment #{n}" }
    association :author, factory: :user

    trait :with_community do
      community { create(:proposal).community }
    end

    factory :topic_with_community, traits: [:with_community]
  end

  factory :related_content do
    association :author, factory: :user
    association :parent_relationable, factory: [:proposal, :debate].sample
    association :child_relationable, factory: [:proposal, :debate].sample

    trait :proposals do
      association :parent_relationable, factory: :proposal
      association :child_relationable, factory: :proposal
    end

    trait :budget_investments do
      association :parent_relationable, factory: :budget_investment
      association :child_relationable, factory: :budget_investment
    end

    trait :from_machine_learning do
      machine_learning { true }
    end
  end

  factory :related_content_score do
    association :user
    association :related_content
  end
end
