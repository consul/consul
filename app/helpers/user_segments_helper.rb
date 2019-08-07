module UserSegmentsHelper
  def user_segments_options
    UserSegments.segments.map { |name, description| [description, name] }
  end

  def segment_name(segment_name)
    UserSegments.segments[segment_name] ||
      I18n.t("admin.segment_recipient.invalid_recipients_segment")
  end
end
