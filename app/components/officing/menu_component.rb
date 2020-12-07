class Officing::MenuComponent < ApplicationComponent
  delegate :current_user, to: :controller
  attr_reader :user

  def initialize(user)
    @user = user
  end

  private

    def vote_collection_shift?
      current_user.poll_officer.officer_assignments.voting_days.where(date: Time.current.to_date).any?
    end

    def final_recount_shift?
      current_user.poll_officer.officer_assignments.final.where(date: Time.current.to_date).any?
    end
end
