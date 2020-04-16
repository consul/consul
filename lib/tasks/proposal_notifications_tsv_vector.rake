namespace :proposal_notifications do
  desc "Updates all proposal_notifications to recalculate their tsv column"
  task touch: :environment do
    ProposalNotification.with_hidden.find_each do |proposal_notification|
      if proposal_notification.save
        print "."
      else
        print "X"
      end
    end
  end
end
