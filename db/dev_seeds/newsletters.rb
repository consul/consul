section "Creating Newsletters" do
  newsletter_body = [
    "We choose to go to the moon in this decade and do the other things, not because they are easy"\
    ", but because they are hard, because that goal will serve to organize and measure the best of"\
    " our energies and skills, because that challenge is one that we are willing to accept, one we"\
    " are unwilling to postpone, and one which we intend to win.",
    "Spaceflights cannot be stopped. This is not the work of any one man or even a group of men."\
    " It is a historical process which mankind is carrying out in accordance with the natural laws"\
    " of human development.",
    "Many say exploration is part of our destiny, but it’s actually our duty to future generations"\
    " and their quest to ensure the survival of the human species."
  ]

  UserSegments.generate_geozone_segments
  5.times do |n|
    Newsletter.create!(
      subject: "Newsletter subject #{n}",
      segment_recipient: UserSegments.segment_names.sample,
      from: "no-reply@consul.dev",
      body: newsletter_body.sample,
      sent_at: [Time.now, nil].sample
    )
  end
end
