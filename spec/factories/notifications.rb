FactoryBot.define do
  factory :notification do
    user
    association :notifiable, factory: :proposal

    trait :read do
      read_at { Time.current }
    end
  end

  factory :admin_notification do
    title             { |n| "Admin Notification title #{n}" }
    body              { |n| "Admin Notification body #{n}" }
    link              nil
    segment_recipient UserSegments.segment_names.sample
    recipients_count  nil
    sent_at           nil

    trait :sent do
      recipients_count 1
      sent_at { Time.current }
    end
  end
end
