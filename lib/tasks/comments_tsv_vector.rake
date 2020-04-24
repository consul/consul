namespace :comments do
  desc "Updates all comments to recalculate their tsv column"
  task touch: :environment do
    Comment.with_hidden.find_each do |comment|
      if comment.save
        print "."
      else
        print "X"
      end
    end
  end
end
