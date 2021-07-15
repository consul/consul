class Comment::Exporter
  def to_json_file(filename)
    comments = []
    Comment.find_each do |comment|
      comments << json_values(comment)
    end
    File.open(filename, "w") do |file|
      file.write(comments.to_json)
    end
  end

  private

    def json_values(comment)
      {
        id: comment.id,
        commentable_id: comment.commentable_id,
        commentable_type: comment.commentable_type,
        body: strip_tags(comment.body)
      }
    end

    def strip_tags(html_string)
      ActionView::Base.full_sanitizer.sanitize(html_string)
    end
end
