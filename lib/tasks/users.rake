namespace :users do
  desc "Generate unsubscribe_hash for existing users"
  task generate_unsubscribe_hash_for_users: :environment do
    User.all.each do |user|
      user.update(unsubscribe_hash: SecureRandom.hex)
    end
  end
end
