class Admin::EmailsDownloadController < Admin::BaseController
  def index
  end

  def generate_csv
    segment_name = params[:users_segment]
    filename = UserSegments.segments[segment_name]

    csv_file = users_segment_emails_csv(segment_name)
    send_data csv_file, filename: "#{filename}.csv"
  end

  private

  def users_segment_emails_csv(segment_name)
    UserSegments.user_segment_emails(segment_name).join(",")
  end
end
