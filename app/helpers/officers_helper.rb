module OfficersHelper
  def no_shifts?
    current_user.poll_officer.officer_assignments.where(date: Time.current.to_date).blank?
  end
end
