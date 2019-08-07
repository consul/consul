FactoryBot.define do
  factory :newsletter do
    sequence(:subject) { |n| "Subject #{n}" }
    segment_recipient  UserSegments.segment_names.sample
    sequence(:from)    { |n| "noreply#{n}@consul.dev" }
    sequence(:body)    { |n| "Body #{n}" }
  end
end
