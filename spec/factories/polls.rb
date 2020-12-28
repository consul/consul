FactoryBot.define do
  factory :poll do
    sequence(:name) { |n| "Poll #{SecureRandom.hex}" }

    slug { "this-is-a-slug" }

    starts_at { 1.month.ago }
    ends_at { 1.month.from_now }

    trait :current do
      starts_at { 2.days.ago }
      ends_at { 2.days.from_now }
    end

    trait :expired do
      starts_at { 1.month.ago }
      ends_at { 15.days.ago }
    end

    trait :old do
      starts_at { 3.months.ago }
      ends_at { 2.months.ago }
    end

    trait :recounting do
      starts_at { 1.month.ago }
      ends_at { Date.current }
    end

    trait :published do
      published { true }
    end

    trait :hidden do
      hidden_at { Time.current }
    end

    trait :for_budget do
      association :budget
    end

    trait :with_image do
      after(:create) { |poll| create(:image, imageable: poll) }
    end

    transient { officers { [] } }

    after(:create) do |poll, evaluator|
      evaluator.officers.each do |officer|
        create(:poll_officer_assignment, poll: poll, officer: officer)
      end
    end
  end

  factory :poll_question, class: "Poll::Question" do
    poll
    association :author, factory: :user
    sequence(:title) { |n| "Question title #{n}" }

    trait :yes_no do
      after(:create) do |question|
        create(:poll_question_answer, question: question, title: "Yes")
        create(:poll_question_answer, question: question, title: "No")
      end
    end
  end

  factory :poll_question_answer, class: "Poll::Question::Answer" do
    sequence(:title) { |n| "Answer title #{n}" }
    sequence(:description) { |n| "Answer description #{n}" }
    sequence(:given_order) { |n| n }

    transient { poll { association(:poll) } }

    question { association(:poll_question, poll: poll) }
  end

  factory :poll_answer_video, class: "Poll::Question::Answer::Video" do
    title { "Sample video title" }
    url { "https://youtu.be/nhuNb0XtRhQ" }

    transient { poll { association(:poll) } }

    answer { association(:poll_question_answer, poll: poll) }
  end

  factory :poll_booth, class: "Poll::Booth" do
    sequence(:name) { |n| "Booth #{n}" }
    sequence(:location) { |n| "Street #{n}" }
  end

  factory :poll_booth_assignment, class: "Poll::BoothAssignment" do
    poll
    association :booth, factory: :poll_booth
  end

  factory :poll_officer_assignment, class: "Poll::OfficerAssignment" do
    association :officer, factory: :poll_officer
    date { Date.current }

    transient { poll { association(:poll) } }
    transient { booth { association(:poll_booth) } }

    booth_assignment do
      association :poll_booth_assignment, poll: poll, booth: booth
    end

    trait :final do
      final { true }
    end
  end

  factory :poll_shift, class: "Poll::Shift" do
    association :booth, factory: :poll_booth
    association :officer, factory: :poll_officer
    date { Date.current }

    trait :vote_collection_task do
      task { 0 }
    end

    trait :recount_scrutiny_task do
      task { 1 }
    end
  end

  factory :poll_voter, class: "Poll::Voter" do
    association :user, :level_two, strategy: :create
    from_web

    transient { budget { nil } }

    poll { budget&.poll || association(:poll, budget: budget) }
    trait :from_web do
      origin { "web" }
      token { SecureRandom.hex(32) }
    end

    trait :from_booth do
      origin { "booth" }

      transient { booth { association(:poll_booth) } }

      booth_assignment do
        association :poll_booth_assignment, poll: poll, booth: booth
      end

      officer_assignment do
        association :poll_officer_assignment,
          booth_assignment: booth_assignment,
          officer: officer || association(:poll_officer)
      end
    end

    trait :valid_document do
      document_type   { "1" }
      document_number { "12345678Z" }
    end

    trait :invalid_document do
      document_type   { "1" }
      document_number { "99999999A" }
    end
  end

  factory :poll_answer, class: "Poll::Answer" do
    association :question, factory: [:poll_question, :yes_no]
    association :author, factory: [:user, :level_two]
    answer { question.question_answers.sample.title }
  end

  factory :poll_partial_result, class: "Poll::PartialResult" do
    association :question, factory: [:poll_question, :yes_no]
    association :author, factory: :user
    origin { "web" }
    answer { question.question_answers.sample.title }
  end

  factory :poll_recount, class: "Poll::Recount" do
    association :author, factory: :user
    origin { "web" }

    trait :from_booth do
      origin { "booth" }

      transient { poll { nil } }

      booth_assignment do
        association :poll_booth_assignment, poll: poll
      end
    end
  end

  factory :poll_ballot_sheet, class: "Poll::BallotSheet" do
    association :poll
    association :officer_assignment, factory: :poll_officer_assignment
    data { "1234;9876;5678\n1000;2000;3000;9999" }
  end

  factory :poll_ballot, class: "Poll::Ballot" do
    association :ballot_sheet, factory: :poll_ballot_sheet
    data { "1,2,3" }
  end

  factory :officing_residence, class: "Officing::Residence" do
    user
    association :officer, factory: :poll_officer
    document_number
    document_type    { "1" }
    year_of_birth    { "1980" }

    trait :invalid do
      year_of_birth { Time.current.year }
    end
  end

  factory :active_poll do
  end
end
