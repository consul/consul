require "rails_helper"

describe "rake users:generate_unsubscribe_hash_for_users" do
  before { User.skip_callback(:create, :before, :add_unsubscribe_hash) }
  after { User.set_callback(:create, :before, :add_unsubscribe_hash) }

  let :run_rake_task do
    Rake.application.invoke_task("users:generate_unsubscribe_hash_for_users")
  end

  it "populates empty databases and assigns targets correctly" do
    user = create(:user)
    expect(user.unsubscribe_hash).not_to be_present

    run_rake_task

    expect(user.reload.unsubscribe_hash).to be_present
  end
end
