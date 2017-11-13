require 'database_cleaner'
DatabaseCleaner.clean_with :truncation
@logger = Logger.new(STDOUT)
@logger.formatter = proc { |_severity, _datetime, _progname, msg| msg }

def section(section_title)
  @logger.info section_title
  yield
  log(' ✅')
end

def log(msg)
  @logger.info "#{msg}\n"
end

section "Creating Settings" do
  Setting.create(key: 'official_level_1_name', value: 'Empleados públicos')
  Setting.create(key: 'official_level_2_name', value: 'Organización Municipal')
  Setting.create(key: 'official_level_3_name', value: 'Directores generales')
  Setting.create(key: 'official_level_4_name', value: 'Concejales')
  Setting.create(key: 'official_level_5_name', value: 'Alcaldesa')
  Setting.create(key: 'max_ratio_anon_votes_on_debates', value: '50')
  Setting.create(key: 'max_votes_for_debate_edit', value: '1000')
  Setting.create(key: 'max_votes_for_proposal_edit', value: '1000')
  Setting.create(key: 'proposal_code_prefix', value: 'MAD')
  Setting.create(key: 'votes_for_proposal_success', value: '100')
  Setting.create(key: 'months_to_archive_proposals', value: '12')
  Setting.create(key: 'comments_body_max_length', value: '1000')

  Setting.create(key: 'twitter_handle', value: '@consul_dev')
  Setting.create(key: 'twitter_hashtag', value: '#consul_dev')
  Setting.create(key: 'facebook_handle', value: 'CONSUL')
  Setting.create(key: 'youtube_handle', value: 'CONSUL')
  Setting.create(key: 'telegram_handle', value: 'CONSUL')
  Setting.create(key: 'instagram_handle', value: 'CONSUL')
  Setting.create(key: 'blog_url', value: '/blog')
  Setting.create(key: 'url', value: 'http://localhost:3000')
  Setting.create(key: 'org_name', value: 'CONSUL')
  Setting.create(key: 'place_name', value: 'City')
  Setting.create(key: 'feature.debates', value: "true")
  Setting.create(key: 'feature.polls', value: "true")
  Setting.create(key: 'feature.spending_proposals', value: nil)
  Setting.create(key: 'feature.spending_proposal_features.voting_allowed', value: nil)
  Setting.create(key: 'feature.budgets', value: "true")
  Setting.create(key: 'feature.twitter_login', value: "true")
  Setting.create(key: 'feature.facebook_login', value: "true")
  Setting.create(key: 'feature.google_login', value: "true")
  Setting.create(key: 'feature.signature_sheets', value: "true")
  Setting.create(key: 'feature.legislation', value: "true")
  Setting.create(key: 'feature.user.recommendations', value: "true")
  Setting.create(key: 'feature.community', value: "true")
  Setting.create(key: 'feature.map', value: "true")
  Setting.create(key: 'per_page_code_head', value: "")
  Setting.create(key: 'per_page_code_body', value: "")
  Setting.create(key: 'comments_body_max_length', value: '1000')
  Setting.create(key: 'mailer_from_name', value: 'CONSUL')
  Setting.create(key: 'mailer_from_address', value: 'noreply@consul.dev')
  Setting.create(key: 'meta_description', value: 'Citizen Participation and Open Government Application')
  Setting.create(key: 'meta_keywords', value: 'citizen participation, open government')
  Setting.create(key: 'verification_offices_url', value: 'http://oficinas-atencion-ciudadano.url/')
  Setting.create(key: 'min_age_to_participate', value: '16')
  Setting.create(key: 'proposal_improvement_path', value: nil)
  Setting.create(key: 'map_latitude', value: 51.48)
  Setting.create(key: 'map_longitude', value: 0.0)
  Setting.create(key: 'map_zoom', value: 10)
  Setting.create(key: 'postal_codes', value: "28000-28099,28100,28200")
end

section "Creating Geozones" do
  Geozone.create(name: "city")
  Geozone.create(name: "Existent District", census_code: "01")
  ('A'..'Z').each { |i| Geozone.create(name: "District #{i}", external_code: i.ord, census_code: i.ord) }
end

section "Creating Users" do
  def create_user(email, username = Faker::Name.name)
    pwd = '12345678'
    User.create!(
      username:               username,
      email:                  email,
      password:               pwd,
      password_confirmation:  pwd,
      confirmed_at:           Time.current,
      terms_of_service:       "1",
      gender:                 ['Male', 'Female'].sample,
      date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
      public_activity:        (rand(1..100) > 30)
    )
  end

  def unique_document_number
    @document_number ||= 12345678
    @document_number += 1
    "#{@document_number}#{[*'A'..'Z'].sample}"
  end

  admin = create_user('admin@consul.dev', 'admin')
  admin.create_administrator
  admin.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
               verified_at: Time.current, document_number: unique_document_number)

  moderator = create_user('mod@consul.dev', 'mod')
  moderator.create_moderator

  manager = create_user('manager@consul.dev', 'manager')
  manager.create_manager

  valuator = create_user('valuator@consul.dev', 'valuator')
  valuator.create_valuator
  valuator.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                  verified_at: Time.current, document_number: unique_document_number)

  poll_officer = create_user('poll_officer@consul.dev', 'Paul O. Fisher')
  poll_officer.create_poll_officer
  poll_officer.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                      verified_at: Time.current, document_number: unique_document_number)

  poll_officer2 = create_user('poll_officer2@consul.dev', 'Pauline M. Espinosa')
  poll_officer2.create_poll_officer
  poll_officer2.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                       verified_at: Time.current, document_number: unique_document_number)

  create_user('unverified@consul.dev', 'unverified')

  level_2 = create_user('leveltwo@consul.dev', 'level 2')
  level_2.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number,
                 document_number: unique_document_number, document_type: "1")

  verified = create_user('verified@consul.dev', 'verified')
  verified.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number, document_type: "1",
                  verified_at: Time.current, document_number: unique_document_number)

  (1..10).each do |i|
    org_name = Faker::Company.name
    org_user = create_user("org#{i}@consul.dev", org_name)
    org_responsible_name = Faker::Name.name
    org = org_user.create_organization(name: org_name, responsible_name: org_responsible_name)

    verified = [true, false].sample
    if verified
      org.verify
    else
      org.reject
    end
  end

  (1..5).each do |i|
    official = create_user("official#{i}@consul.dev")
    official.update(official_level: i, official_position: "Official position #{i}")
  end

  (1..100).each do |i|
    user = create_user("user#{i}@consul.dev")
    level = [1, 2, 3].sample
    if level >= 2
      user.update(residence_verified_at: Time.current, confirmed_phone: Faker::PhoneNumber.phone_number,
                  document_number: unique_document_number, document_type: "1", geozone: Geozone.all.sample)
    end
    if level == 3
      user.update(verified_at: Time.current, document_number: unique_document_number)
    end
  end
end

section "Creating Tags Categories" do
  ActsAsTaggableOn::Tag.category.create!(name: "Asociaciones")
  ActsAsTaggableOn::Tag.category.create!(name: "Cultura")
  ActsAsTaggableOn::Tag.category.create!(name: "Deportes")
  ActsAsTaggableOn::Tag.category.create!(name: "Derechos Sociales")
  ActsAsTaggableOn::Tag.category.create!(name: "Economía")
  ActsAsTaggableOn::Tag.category.create!(name: "Empleo")
  ActsAsTaggableOn::Tag.category.create!(name: "Equidad")
  ActsAsTaggableOn::Tag.category.create!(name: "Sostenibilidad")
  ActsAsTaggableOn::Tag.category.create!(name: "Participación")
  ActsAsTaggableOn::Tag.category.create!(name: "Movilidad")
  ActsAsTaggableOn::Tag.category.create!(name: "Medios")
  ActsAsTaggableOn::Tag.category.create!(name: "Salud")
  ActsAsTaggableOn::Tag.category.create!(name: "Transparencia")
  ActsAsTaggableOn::Tag.category.create!(name: "Seguridad y Emergencias")
  ActsAsTaggableOn::Tag.category.create!(name: "Medio Ambiente")
end

section "Creating Debates" do
  tags = Faker::Lorem.words(25)
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    debate = Debate.create!(author: author,
                            title: Faker::Lorem.sentence(3).truncate(60),
                            created_at: rand((Time.current - 1.week)..Time.current),
                            description: description,
                            tag_list: tags.sample(3).join(','),
                            geozone: Geozone.all.sample,
                            terms_of_service: "1")
  end

  tags = ActsAsTaggableOn::Tag.where(kind: 'category')
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    debate = Debate.create!(author: author,
                            title: Faker::Lorem.sentence(3).truncate(60),
                            created_at: rand((Time.current - 1.week)..Time.current),
                            description: description,
                            tag_list: tags.sample(3).join(','),
                            geozone: Geozone.all.sample,
                            terms_of_service: "1")
  end
end

section "Creating Proposals" do
  tags = Faker::Lorem.words(25)
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                question: Faker::Lorem.sentence(3) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                created_at: rand((Time.current - 1.week)..Time.current),
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                terms_of_service: "1")
  end
end

section "Creating Archived Proposals" do
  tags = Faker::Lorem.words(25)
  5.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                question: Faker::Lorem.sentence(3) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                terms_of_service: "1",
                                created_at: Setting["months_to_archive_proposals"].to_i.months.ago)
  end
end

section "Creating Successful Proposals" do
  tags = Faker::Lorem.words(25)
  10.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                question: Faker::Lorem.sentence(3) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                created_at: rand((Time.current - 1.week)..Time.current),
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                terms_of_service: "1",
                                cached_votes_up: Setting["votes_for_proposal_success"])
  end

  tags = ActsAsTaggableOn::Tag.where(kind: 'category')
  30.times do
    author = User.all.sample
    description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
    proposal = Proposal.create!(author: author,
                                title: Faker::Lorem.sentence(3).truncate(60),
                                question: Faker::Lorem.sentence(3) + "?",
                                summary: Faker::Lorem.sentence(3),
                                responsible_name: Faker::Name.name,
                                external_url: Faker::Internet.url,
                                description: description,
                                created_at: rand((Time.current - 1.week)..Time.current),
                                tag_list: tags.sample(3).join(','),
                                geozone: Geozone.all.sample,
                                terms_of_service: "1")
  end
end

section "Commenting Debates" do
  100.times do
    author = User.all.sample
    debate = Debate.all.sample
    Comment.create!(user: author,
                    created_at: rand(debate.created_at..Time.current),
                    commentable: debate,
                    body: Faker::Lorem.sentence)
  end
end

section "Commenting Proposals" do
  100.times do
    author = User.all.sample
    proposal = Proposal.all.sample
    Comment.create!(user: author,
                    created_at: rand(proposal.created_at..Time.current),
                    commentable: proposal,
                    body: Faker::Lorem.sentence)
  end
end

section "Commenting Comments" do
  200.times do
    author = User.all.sample
    parent = Comment.all.sample
    Comment.create!(user: author,
                    created_at: rand(parent.created_at..Time.current),
                    commentable_id: parent.commentable_id,
                    commentable_type: parent.commentable_type,
                    body: Faker::Lorem.sentence,
                    parent: parent)
  end
end

section "Voting Debates, Proposals & Comments" do
  not_org_users = User.where(['users.id NOT IN(?)', User.organizations.pluck(:id)])
  100.times do
    voter  = not_org_users.level_two_or_three_verified.all.sample
    vote   = [true, false].sample
    debate = Debate.all.sample
    debate.vote_by(voter: voter, vote: vote)
  end

  100.times do
    voter  = not_org_users.all.sample
    vote   = [true, false].sample
    comment = Comment.all.sample
    comment.vote_by(voter: voter, vote: vote)
  end

  100.times do
    voter = not_org_users.level_two_or_three_verified.all.sample
    proposal = Proposal.all.sample
    proposal.vote_by(voter: voter, vote: true)
  end
end

section "Flagging Debates & Comments" do
  40.times do
    debate = Debate.all.sample
    flagger = User.where(["users.id <> ?", debate.author_id]).all.sample
    Flag.flag(flagger, debate)
  end

  40.times do
    comment = Comment.all.sample
    flagger = User.where(["users.id <> ?", comment.user_id]).all.sample
    Flag.flag(flagger, comment)
  end

  40.times do
    proposal = Proposal.all.sample
    flagger = User.where(["users.id <> ?", proposal.author_id]).all.sample
    Flag.flag(flagger, proposal)
  end
end

section "Creating Spending Proposals" do
tags = Faker::Lorem.words(10)
60.times do
  geozone = Geozone.all.sample
  author = User.all.sample
  description = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  feasible_explanation = "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>"
  valuation_finished = [true, false].sample
  feasible = [true, false].sample
  spending_proposal = SpendingProposal.create!(author: author,
                                               title: Faker::Lorem.sentence(3).truncate(60),
                                               external_url: Faker::Internet.url,
                                               description: description,
                                               created_at: rand((Time.current - 1.week)..Time.current),
                                               geozone: [geozone, nil].sample,
                                               feasible: feasible,
                                               feasible_explanation: feasible_explanation,
                                               valuation_finished: valuation_finished,
                                               tag_list: tags.sample(3).join(','),
                                               price: rand(1000000),
                                               terms_of_service: "1")
end
end

section "Creating Valuation Assignments" do
  (1..17).to_a.sample.times do
    SpendingProposal.all.sample.valuators << Valuator.first
  end
end

section "Creating Budgets" do
  Budget::PHASES.each_with_index do |phase, i|
    descriptions = Hash[Budget::PHASES.map do |p|
      ["description_#{p}",
       "<p>#{Faker::Lorem.paragraphs(2).join('</p><p>')}</p>"]
    end]
    budget = Budget.create!(
      descriptions.merge(
        name: (Date.current - 10 + i).to_s,
        currency_symbol: "€",
        phase: phase
      )
    )

    (1..([1, 2, 3].sample)).each do |k|
      group = budget.groups.create!(name: "#{Faker::StarWars.planet} #{k}")

      geozones = Geozone.reorder("RANDOM()").limit([2, 5, 6, 7].sample)
      geozones.each do |geozone|
        group.headings << group.headings.create!(name: "#{geozone.name} #{k}",
                                                 price: rand(1..100) * 100000,
                                                 population: rand(1..50) * 10000)
      end
    end
  end
end

section "Creating Investments" do
  tags = Faker::Lorem.words(10)
  100.times do
    heading = Budget::Heading.all.sample

    investment = Budget::Investment.create!(
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      external_url: Faker::Internet.url,
      description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: %w{undecided unfeasible feasible feasible feasible feasible}.sample,
      unfeasibility_explanation: Faker::Lorem.paragraph,
      valuation_finished: [false, true].sample,
      tag_list: tags.sample(3).join(','),
      price: rand(1..100) * 100000,
      terms_of_service: "1"
    )
  end
end

section "Balloting Investments" do
  Budget.balloting.last.investments.each do |investment|
    investment.update(selected: true, feasibility: "feasible")
  end
end

section "Winner Investments" do
  budget = Budget.where(phase: "finished").last
  100.times do
    heading = budget.headings.all.sample
    investment = Budget::Investment.create!(
      author: User.all.sample,
      heading: heading,
      group: heading.group,
      budget: heading.group.budget,
      title: Faker::Lorem.sentence(3).truncate(60),
      external_url: Faker::Internet.url,
      description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>",
      created_at: rand((Time.current - 1.week)..Time.current),
      feasibility: "feasible",
      valuation_finished: true,
      selected: true,
      price: rand(10000..heading.price),
      terms_of_service: "1"
    )
  end
  budget.headings.each do |heading|
    Budget::Result.new(budget, heading).calculate_winners
  end
end

section "Creating Valuation Assignments" do
  (1..50).to_a.sample.times do
    Budget::Investment.all.sample.valuators << Valuator.first
  end
end

section "Ignoring flags in Debates, comments & proposals" do
  Debate.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
  Comment.flagged.reorder("RANDOM()").limit(30).each(&:ignore_flag)
  Proposal.flagged.reorder("RANDOM()").limit(10).each(&:ignore_flag)
end

section "Hiding debates, comments & proposals" do
  Comment.with_hidden.flagged.reorder("RANDOM()").limit(30).each(&:hide)
  Debate.with_hidden.flagged.reorder("RANDOM()").limit(5).each(&:hide)
  Proposal.with_hidden.flagged.reorder("RANDOM()").limit(10).each(&:hide)
end

section "Confirming hiding in debates, comments & proposals" do
  Comment.only_hidden.flagged.reorder("RANDOM()").limit(10).each(&:confirm_hide)
  Debate.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)
  Proposal.only_hidden.flagged.reorder("RANDOM()").limit(5).each(&:confirm_hide)
end

section "Creating banners" do
  Proposal.last(3).each do |proposal|
    title = Faker::Lorem.sentence(word_count = 3)
    description = Faker::Lorem.sentence(word_count = 12)
    banner = Banner.create!(title: title,
                            description: description,
                            style: ["banner-style banner-style-one", "banner-style banner-style-two",
                                    "banner-style banner-style-three"].sample,
                            image: ["banner-img banner-img-one", "banner-img banner-img-two",
                                    "banner-img banner-img-three"].sample,
                            target_url: Rails.application.routes.url_helpers.proposal_path(proposal),
                            post_started_at: rand((Time.current - 1.week)..(Time.current - 1.day)),
                            post_ended_at:   rand((Time.current - 1.day)..(Time.current + 1.week)),
                            created_at: rand((Time.current - 1.week)..Time.current))
  end
end

section "Creating proposal notifications" do
  100.times do |i|
    ProposalNotification.create!(title: "Proposal notification title #{i}",
                                 body: "Proposal notification body #{i}",
                                 author: User.all.sample,
                                 proposal: Proposal.all.sample)
  end
end

section "Creating polls" do

  Poll.create(name: "Current Poll",
              # TODO: Uncomment when Poll get slugs
              # slug: "current-poll",
              starts_at: 7.days.ago,
              ends_at:   7.days.from_now,
              geozone_restricted: false)

  Poll.create(name: "Current Poll Geozone Restricted",
              # TODO: Uncomment when Poll get slugs
              # slug: "current-poll-geozone-restricted",
              starts_at: 5.days.ago,
              ends_at:   5.days.from_now,
              geozone_restricted: true,
              geozones: Geozone.reorder("RANDOM()").limit(3))

  Poll.create(name: "Incoming Poll",
              # TODO: Uncomment when Poll get slugs
              # slug: "incoming-poll",
              starts_at: 1.month.from_now,
              ends_at:   2.months.from_now)

  Poll.create(name: "Recounting Poll",
              # TODO: Uncomment when Poll get slugs
              # slug: "recounting-poll",
              starts_at: 15.days.ago,
              ends_at:   2.days.ago)

  Poll.create(name: "Expired Poll without Stats & Results",
              # TODO: Uncomment when Poll get slugs
              # slug: "expired-poll-without-stats-and-results",
              starts_at: 2.months.ago,
              ends_at:   1.month.ago)

  Poll.create(name: "Expired Poll with Stats & Results",
              # TODO: Uncomment when Poll get slugs
              # slug: "expired-poll-with-stats-and-results",
              starts_at: 2.months.ago,
              ends_at:   1.month.ago,
              results_enabled: true,
              stats_enabled: true)
end

section "Creating Poll Questions & Answers" do
  Poll.all.each do |poll|
    (1..4).to_a.sample.times do
      question = Poll::Question.create!(author: User.all.sample,
                                        title: Faker::Lorem.sentence(3).truncate(60) + '?',
                                        poll: poll)
      Faker::Lorem.words((2..4).to_a.sample).each do |answer|
        Poll::Question::Answer.create!(question: question,
                                       title: answer.capitalize,
                                       description: "<p>#{Faker::Lorem.paragraphs.join('</p><p>')}</p>")
      end
    end
  end
end

section "Creating Poll Booths & BoothAssignments" do
  20.times do |i|
    Poll::Booth.create(name: "Booth #{i}", location: Faker::Address.street_address, polls: [Poll.all.sample])
  end
end

section "Creating Poll Shifts for Poll Officers" do
  Poll.all.each do |poll|
    Poll::BoothAssignment.where(poll: poll).each do |booth_assignment|
      Poll::Officer.all.each do |poll_officer|
        {
          vote_collection: (poll.starts_at.to_datetime..poll.ends_at.to_datetime),
          recount_scrutiny: (poll.ends_at.to_datetime..poll.ends_at.to_datetime + Poll::RECOUNT_DURATION)
        }.each do |task_name, task_dates|
          task_dates.each do |shift_date|
            Poll::Shift.create(booth: booth_assignment.booth,
                               officer: poll_officer,
                               date: shift_date,
                               officer_name: poll_officer.name,
                               officer_email: poll_officer.email,
                               task: task_name)
          end
        end
      end
    end
  end
end

section "Commenting Poll Questions" do
  30.times do
    author = User.all.sample
    question = Poll::Question.all.sample
    Comment.create!(user: author,
                    created_at: rand(question.created_at..Time.current),
                    commentable: question,
                    body: Faker::Lorem.sentence)
  end
end

section "Creating Poll Voters" do

  def vote_poll_on_booth(user, poll)
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: 'booth',
                        officer: Poll::Officer.all.sample)
  end

  def vote_poll_on_web(user, poll)
    randomly_answer_questions(poll, user)
    Poll::Voter.create!(document_type: user.document_type,
                        document_number: user.document_number,
                        user: user,
                        poll: poll,
                        origin: 'web',
                        token: SecureRandom.hex(32))
  end

  def randomly_answer_questions(poll, user)
    poll.questions.each do |question|
      next unless [true, false].sample
      Poll::Answer.create!(question_id: question.id, author: user, answer: question.question_answers.sample.title)
    end
  end

  (Poll.expired + Poll.current + Poll.recounting).uniq.each do |poll|
    level_two_verified_users = User.level_two_verified
    level_two_verified_users = level_two_verified_users.where(geozone_id: poll.geozone_ids) if poll.geozone_restricted?
    user_groups = level_two_verified_users.in_groups(2)
    user_groups.first.each { |user| vote_poll_on_booth(user, poll) }
    user_groups.second.compact.each { |user| vote_poll_on_web(user, poll) }
  end
end

section "Creating Poll Recounts" do
  Poll.all.each do |poll|
    poll.booth_assignments.each do |booth_assignment|
      officer_assignment = poll.officer_assignments.first
      author = Poll::Officer.first.user

      Poll::Recount.create!(officer_assignment: officer_assignment,
                            booth_assignment: booth_assignment,
                            author: author,
                            date: poll.ends_at,
                            white_amount: rand(0..10),
                            null_amount: rand(0..10),
                            total_amount: rand(100..9999),
                            origin: "booth")
    end
  end
end

section "Creating Poll Results" do
  Poll.all.each do |poll|
    poll.booth_assignments.each do |booth_assignment|
      officer_assignment = poll.officer_assignments.first
      author = Poll::Officer.first.user

      poll.questions.each do |question|
        question.question_answers.each do |answer|
          Poll::PartialResult.create!(officer_assignment: officer_assignment,
                                      booth_assignment: booth_assignment,
                                      date: Date.current,
                                      question: question,
                                      answer: answer.title,
                                      author: author,
                                      amount: rand(999),
                                      origin: "booth")
        end
      end
    end
  end
end

section "Creating Poll Questions from Proposals" do
  3.times do
    proposal = Proposal.all.sample
    poll = Poll.current.first
    question = Poll::Question.create(poll: poll)
    Faker::Lorem.words((2..4).to_a.sample).each do |answer|
      Poll::Question::Answer.create!(question: question, title: answer.capitalize, description: Faker::ChuckNorris.fact)
    end
    question.copy_attributes_from_proposal(proposal)
    question.save!
  end
end

section "Creating Successful Proposals" do
  10.times do
    proposal = Proposal.all.sample
    poll = Poll.current.first
    question = Poll::Question.create(poll: poll)
    Faker::Lorem.words((2..4).to_a.sample).each do |answer|
      Poll::Question::Answer.create!(question: question, title: answer.capitalize, description: Faker::ChuckNorris.fact)
    end
    question.copy_attributes_from_proposal(proposal)
    question.save!
  end
end

section "Creating legislation processes" do
  5.times do
    process = ::Legislation::Process.create!(title: Faker::Lorem.sentence(3).truncate(60),
                                             description: Faker::Lorem.paragraphs.join("\n\n"),
                                             summary: Faker::Lorem.paragraph,
                                             additional_info: Faker::Lorem.paragraphs.join("\n\n"),
                                             start_date: Date.current - 3.days,
                                             end_date: Date.current + 3.days,
                                             debate_start_date: Date.current - 3.days,
                                             debate_end_date: Date.current - 1.day,
                                             draft_publication_date: Date.current + 1.day,
                                             allegations_start_date: Date.current + 2.days,
                                             allegations_end_date: Date.current + 3.days,
                                             result_publication_date: Date.current + 4.days,
                                             debate_phase_enabled: true,
                                             allegations_phase_enabled: true,
                                             draft_publication_enabled: true,
                                             result_publication_enabled: true,
                                             published: true)
  end

  ::Legislation::Process.all.each do |process|
    (1..3).each do |i|
      version = process.draft_versions.create!(title: "Version #{i}",
                                               body: Faker::Lorem.paragraphs.join("\n\n"))
    end
  end
end

log "All dev seeds created successfuly 👍"
