FactoryBot.define do
  factory :image do
    attachment { File.new("spec/fixtures/files/clippy.jpg") }
    title { "Lorem ipsum dolor sit amet" }
    association :user, factory: :user, strategy: :create

    trait :proposal_image do
      association :imageable, factory: :proposal
    end

    trait :budget_investment_image do
      association :imageable, factory: :budget_investment
    end
  end

  factory :document do
    sequence(:title) { |n| "Document title #{n}" }
    association :user, factory: :user
    attachment { File.new("spec/fixtures/files/empty.pdf") }

    trait :proposal_document do
      association :documentable, factory: :proposal
    end

    trait :budget_investment_document do
      association :documentable, factory: :budget_investment
    end

    trait :poll_question_document do
      association :documentable, factory: :poll_question
    end

    trait :admin do
      admin { true }
    end
  end

  factory :direct_upload do
    user

    trait :proposal do
      resource_type { "Proposal" }
    end
    trait :budget_investment do
      resource_type { "Budget::Investment" }
    end

    trait :documents do
      resource_relation { "documents" }
      attachment { File.new("spec/fixtures/files/empty.pdf") }
    end
    trait :image do
      resource_relation { "image" }
      attachment { File.new("spec/fixtures/files/clippy.jpg") }
    end
    initialize_with { new(attributes) }
  end
end
