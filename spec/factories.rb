FactoryGirl.define do
  factory :local_census_record, class: 'LocalCensusRecord' do
    document_number '12345678A'
    document_type 1
    date_of_birth Date.new(1970, 1, 31)
    postal_code '28002'
  end

  sequence(:document_number) { |n| "#{n.to_s.rjust(8, '0')}X" }

  factory :user do
    sequence(:username) { |n| "Manuela#{n}" }
    sequence(:email)    { |n| "manuela#{n}@consul.dev" }

    password            'judgmentday'
    terms_of_service    '1'
    confirmed_at        { Time.current }
    public_activity     true

    trait :incomplete_verification do
      after :create do |user|
        create(:failed_census_call, user: user)
      end
    end

    trait :level_two do
      residence_verified_at Time.current
      unconfirmed_phone "611111111"
      confirmed_phone "611111111"
      sms_confirmation_code "1234"
      document_type "1"
      document_number
      date_of_birth Date.new(1980, 12, 31)
      gender "female"
      geozone
    end

    trait :level_three do
      verified_at Time.current
      document_type "1"
      document_number
    end

    trait :hidden do
      hidden_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
    end

    trait :verified do
      verified_at Time.current
    end

    trait :in_census do
      document_number "12345678Z"
      document_type "1"
      verified_at Time.current
    end
  end

  factory :identity do
    user nil
    provider "Twitter"
    uid "MyString"
  end

  factory :activity do
    user
    action "hide"
    association :actionable, factory: :proposal
  end

  factory :verification_residence, class: Verification::Residence do
    user
    document_number
    document_type    "1"
    date_of_birth    Date.new(1980, 12, 31)
    postal_code      "28013"
    terms_of_service '1'

    trait :invalid do
      postal_code "28001"
    end
  end

  factory :failed_census_call do
    user
    document_number
    document_type 1
    date_of_birth Date.new(1900, 1, 1)
    postal_code '28000'
  end

  factory :verification_sms, class: Verification::Sms do
    phone "699999999"
  end

  factory :verification_letter, class: Verification::Letter do
    user
    email 'user@consul.dev'
    password '1234'
    verification_code '5555'
  end

  factory :lock do
    user
    tries 0
    locked_until Time.current
  end

  factory :verified_user do
    document_number
    document_type 'dni'
  end

  factory :debate do
    sequence(:title)     { |n| "Debate #{n} title" }
    description          'Debate description'
    terms_of_service     '1'
    association :author, factory: :user

    trait :hidden do
      hidden_at Time.current
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
      end
    end

    trait :with_hot_score do
      before(:save) { |d| d.calculate_hot_score }
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end

    trait :conflictive do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
        4.times { create(:vote, votable: debate) }
      end
    end
  end

  factory :proposal do
    sequence(:title)     { |n| "Proposal #{n} title" }
    sequence(:summary)   { |n| "In summary, what we want is... #{n}" }
    description          'Proposal description'
    question             'Proposal question'
    external_url         'http://external_documention.es'
    video_url            'https://youtu.be/nhuNb0XtRhQ'
    responsible_name     'John Snow'
    terms_of_service     '1'
    association :author, factory: :user

    trait :hidden do
      hidden_at Time.current
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
    end

    trait :flagged do
      after :create do |proposal|
        Flag.flag(FactoryGirl.create(:user), proposal)
      end
    end

    trait :archived do
      created_at 25.months.ago
    end

    trait :with_hot_score do
      before(:save) { |d| d.calculate_hot_score }
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end

    trait :conflictive do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
        4.times { create(:vote, votable: debate) }
      end
    end

    trait :successful do
      cached_votes_up { Proposal.votes_needed_for_success + 100 }
    end
  end

  factory :spending_proposal do
    sequence(:title)     { |n| "Spending Proposal #{n} title" }
    description          'Spend money on this'
    feasible_explanation 'This proposal is not viable because...'
    external_url         'http://external_documention.org'
    terms_of_service     '1'
    association :author, factory: :user
  end

  factory :budget do
    sequence(:name) { |n| "Budget #{n}" }
    currency_symbol "€"
    phase 'accepting'
    description_accepting "This budget is accepting"
    description_reviewing "This budget is reviewing"
    description_selecting "This budget is selecting"
    description_valuating "This budget is valuating"
    description_balloting "This budget is balloting"
    description_reviewing_ballots "This budget is reviewing ballots"
    description_finished "This budget is finished"

    trait :accepting do
      phase 'accepting'
    end

    trait :reviewing do
      phase 'reviewing'
    end

    trait :selecting do
      phase 'selecting'
    end

    trait :valuating do
      phase 'valuating'
    end

    trait :balloting do
      phase 'balloting'
    end

    trait :reviewing_ballots do
      phase 'reviewing_ballots'
    end

    trait :finished do
      phase 'finished'
    end
  end

  factory :budget_group, class: 'Budget::Group' do
    budget
    sequence(:name) { |n| "Group #{n}" }
  end

  factory :budget_heading, class: 'Budget::Heading' do
    association :group, factory: :budget_group
    sequence(:name) { |n| "Heading #{n}" }
    price 1000000
    population 1234
  end

  factory :budget_investment, class: 'Budget::Investment' do
    sequence(:title) { |n| "Budget Investment #{n} title" }
    association :heading, factory: :budget_heading
    association :author, factory: :user
    description          'Spend money on this'
    price                10
    unfeasibility_explanation ''
    external_url         'http://external_documention.org'
    terms_of_service     '1'
    incompatible          false

    trait :with_confidence_score do
      before(:save) { |i| i.calculate_confidence_score }
    end

    trait :feasible do
      feasibility "feasible"
    end

    trait :unfeasible do
      feasibility "unfeasible"
      unfeasibility_explanation "set to unfeasible on creation"
    end

    trait :undecided do
      feasibility "undecided"
    end

    trait :finished do
      valuation_finished true
    end

    trait :selected do
      selected true
      feasibility "feasible"
      valuation_finished true

    end

    trait :winner do
      selected
      winner true
    end

    trait :incompatible do
      selected
      incompatible true
    end

    trait :unselected do
      selected false
      feasibility "feasible"
      valuation_finished true
    end

  end

  factory :image do
    attachment { File.new("spec/fixtures/files/clippy.jpg") }
    title "Lorem ipsum dolor sit amet"
    association :user, factory: :user

    trait :proposal_image do
      association :imageable, factory: :proposal
    end

    trait :budget_investment_image do
      association :imageable, factory: :budget_investment
    end
  end

  factory :budget_ballot, class: 'Budget::Ballot' do
    association :user, factory: :user
    budget
  end

  factory :budget_ballot_line, class: 'Budget::Ballot::Line' do
    association :ballot, factory: :budget_ballot
    association :investment, factory: :budget_investment
  end

  factory :budget_reclassified_vote, class: 'Budget::ReclassifiedVote' do
    user
    association :investment, factory: :budget_investment
    reason "unfeasible"
  end

  factory :budget_investment_milestone, class: 'Budget::Investment::Milestone' do
    association :investment, factory: :budget_investment
    sequence(:title)     { |n| "Budget investment milestone #{n} title" }
    description          'Milestone description'
  end

  factory :vote do
    association :votable, factory: :debate
    association :voter,   factory: :user
    vote_flag true
    after(:create) do |vote, _|
      vote.votable.update_cached_votes
    end
  end

  factory :flag do
    association :flaggable, factory: :debate
    association :user, factory: :user
  end

  factory :follow do
    association :user, factory: :user

    trait :followed_proposal do
      association :followable, factory: :proposal
    end

    trait :followed_investment do
      association :followable, factory: :budget_investment
    end
  end

  factory :document do
    sequence(:title) { |n| "Document title #{n}" }
    association :user, factory: :user
    attachment { File.new("spec/fixtures/files/empty.pdf") }

    trait :proposal_document do
      association :documentable, factory: :proposal
    end

    trait :budget_investment_document do
      association :documentable, factory: :budget_investment
    end

    trait :poll_question_document do
      association :documentable, factory: :poll_question
    end
  end

  factory :comment do
    association :commentable, factory: :debate
    user
    sequence(:body) { |n| "Comment body #{n}" }

    trait :hidden do
      hidden_at Time.current
    end

    trait :with_ignored_flag do
      ignored_flag_at Time.current
    end

    trait :with_confirmed_hide do
      confirmed_hide_at Time.current
    end

    trait :flagged do
      after :create do |debate|
        Flag.flag(FactoryGirl.create(:user), debate)
      end
    end

    trait :with_confidence_score do
      before(:save) { |d| d.calculate_confidence_score }
    end
  end

  factory :legacy_legislation do
    sequence(:title) { |n| "Legacy Legislation #{n}" }
    body "In order to achieve this..."
  end

  factory :annotation do
    quote "ipsum"
    text "Loremp ipsum dolor"
    ranges [{"start" => "/div[1]", "startOffset" => 5, "end" => "/div[1]", "endOffset" => 10}]
    legacy_legislation
    user
  end

  factory :administrator do
    user
  end

  factory :moderator do
    user
  end

  factory :valuator do
    user
  end

  factory :manager do
    user
  end

  factory :poll_officer, class: 'Poll::Officer' do
    user
  end

  factory :poll do
    sequence(:name) { |n| "Poll #{SecureRandom.hex}" }

    starts_at { 1.month.ago }
    ends_at { 1.month.from_now }

    trait :current do
      starts_at { 2.days.ago }
      ends_at { 2.days.from_now }
    end

    trait :incoming do
      starts_at { 2.days.from_now }
      ends_at { 1.month.from_now }
    end

    trait :expired do
      starts_at { 1.month.ago }
      ends_at { 15.days.ago }
    end

    trait :recounting do
      starts_at { 1.month.ago }
      ends_at { Date.current }
    end

    trait :published do
      published true
    end
  end

  factory :poll_question, class: 'Poll::Question' do
    poll
    association :author, factory: :user
    sequence(:title) { |n| "Question title #{n}" }

    trait :with_answers do
      after(:create) do |question, _evaluator|
        create(:poll_question_answer, question: question, title: "Yes")
        create(:poll_question_answer, question: question, title: "No")
      end
    end
  end

  factory :poll_question_answer, class: 'Poll::Question::Answer' do
    association :question, factory: :poll_question
    sequence(:title) { |n| "Answer title #{n}" }
    sequence(:description) { |n| "Answer description #{n}" }
  end

  factory :poll_answer_video, class: 'Poll::Question::Answer::Video' do
    association :answer, factory: :poll_question_answer
    title "Sample video title"
    url "https://youtu.be/nhuNb0XtRhQ"
  end

  factory :poll_booth, class: 'Poll::Booth' do
    sequence(:name) { |n| "Booth #{n}" }
    sequence(:location) { |n| "Street #{n}" }
  end

  factory :poll_booth_assignment, class: 'Poll::BoothAssignment' do
    poll
    association :booth, factory: :poll_booth
  end

  factory :poll_officer_assignment, class: 'Poll::OfficerAssignment' do
    association :officer, factory: :poll_officer
    association :booth_assignment, factory: :poll_booth_assignment
    date Date.current

    trait :final do
      final true
    end
  end

  factory :poll_shift, class: 'Poll::Shift' do
    association :booth, factory: :poll_booth
    association :officer, factory: :poll_officer
    date Date.current

    trait :vote_collection_task do
      task 0
    end

    trait :recount_scrutiny_task do
      task 1
    end
  end

  factory :poll_voter, class: 'Poll::Voter' do
    poll
    association :user, :level_two
    association :officer, factory: :poll_officer
    origin "web"

    trait :from_booth do
      association :booth_assignment, factory: :poll_booth_assignment
    end

    trait :valid_document do
      document_type   "1"
      document_number "12345678Z"
    end

    trait :invalid_document do
      document_type   "1"
      document_number "99999999A"
    end
  end

  factory :poll_answer, class: 'Poll::Answer' do
    association :question, factory: [:poll_question, :with_answers]
    association :author, factory: [:user, :level_two]
    answer { question.question_answers.sample.title }
  end

  factory :poll_partial_result, class: 'Poll::PartialResult' do
    association :question, factory: [:poll_question, :with_answers]
    association :author, factory: :user
    origin { 'web' }
    answer { question.question_answers.sample.title }
  end

  factory :poll_recount, class: 'Poll::Recount' do
    association :author, factory: :user
    origin { 'web' }
  end

  factory :officing_residence, class: 'Officing::Residence' do
    user
    association :officer, factory: :poll_officer
    document_number
    document_type    "1"
    year_of_birth    "1980"

    trait :invalid do
      year_of_birth Time.current.year
    end
  end

  factory :organization do
    user
    responsible_name "Johnny Utah"
    sequence(:name) { |n| "org#{n}" }

    trait :verified do
      verified_at Time.current
    end

    trait :rejected do
      rejected_at Time.current
    end
  end

  factory :tag, class: 'ActsAsTaggableOn::Tag' do
    sequence(:name) { |n| "Tag #{n} name" }

    trait :category do
      kind "category"
    end
  end

  factory :setting do
    sequence(:key) { |n| "Setting Key #{n}" }
    sequence(:value) { |n| "Setting #{n} Value" }
  end

  factory :ahoy_event, class: Ahoy::Event do
    id { SecureRandom.uuid }
    time DateTime.current
    sequence(:name) {|n| "Event #{n} type"}
  end

  factory :visit  do
    id { SecureRandom.uuid }
    started_at DateTime.current
  end

  factory :campaign do
    sequence(:name) { |n| "Campaign #{n}" }
    sequence(:track_id) { |n| n.to_s }
  end

  factory :notification do
    user
    association :notifiable, factory: :proposal
  end

  factory :geozone do
    sequence(:name) { |n| "District #{n}" }
    sequence(:external_code) { |n| n.to_s }
    sequence(:census_code) { |n| n.to_s }

    trait :in_census do
      census_code "01"
    end
  end

  factory :banner do
    sequence(:title) { |n| "Banner title #{n}" }
    sequence(:description) { |n| "This is the text of Banner #{n}" }
    style {["banner-style-one", "banner-style-two", "banner-style-three"].sample}
    image {["banner.banner-img-one", "banner.banner-img-two", "banner.banner-img-three"].sample}
    target_url {["/proposals", "/debates" ].sample}
    post_started_at Time.current - 7.days
    post_ended_at Time.current + 7.days
  end

  factory :proposal_notification do
    sequence(:title) { |n| "Thank you for supporting my proposal #{n}" }
    sequence(:body) { |n| "Please let others know so we can make it happen #{n}" }
    proposal
  end

  factory :direct_message do
    title    "Hey"
    body     "How are You doing?"
    association :sender,   factory: :user
    association :receiver, factory: :user
  end

  factory :signature_sheet do
    association :signable, factory: :proposal
    association :author, factory: :user
    document_numbers "123A, 456B, 789C"
  end

  factory :signature do
    signature_sheet
    sequence(:document_number) { |n| "#{n}A" }
  end

  factory :legislation_process, class: 'Legislation::Process' do
    title "A collaborative legislation process"
    description "Description of the process"
    summary "Summary of the process"
    start_date Date.current - 5.days
    end_date Date.current + 5.days
    debate_start_date Date.current - 5.days
    debate_end_date Date.current - 2.days
    draft_publication_date Date.current - 1.day
    allegations_start_date Date.current
    allegations_end_date Date.current + 3.days
    result_publication_date Date.current + 5.days
    debate_phase_enabled true
    allegations_phase_enabled true
    draft_publication_enabled true
    result_publication_enabled true
    published true

    trait :next do
      start_date Date.current + 2.days
      end_date Date.current + 8.days
      debate_start_date Date.current + 2.days
      debate_end_date Date.current + 4.days
      draft_publication_date Date.current + 5.days
      allegations_start_date Date.current + 5.days
      allegations_end_date Date.current + 7.days
      result_publication_date Date.current + 8.days
    end

    trait :past do
      start_date Date.current - 12.days
      end_date Date.current - 2.days
      debate_start_date Date.current - 12.days
      debate_end_date Date.current - 9.days
      draft_publication_date Date.current - 8.days
      allegations_start_date Date.current - 8.days
      allegations_end_date Date.current - 4.days
      result_publication_date Date.current - 2.days
    end

    trait :in_debate_phase do
      start_date Date.current - 5.days
      end_date Date.current + 5.days
      debate_start_date Date.current - 5.days
      debate_end_date Date.current + 1.day
      draft_publication_date Date.current + 1.day
      allegations_start_date Date.current + 2.days
      allegations_end_date Date.current + 3.days
      result_publication_date Date.current + 5.days
    end

    trait :not_published do
      published false
    end

  end

  factory :has_phases_phase, class: "HasPhases::Phase" do
    start_date Date.current + 1.day
    end_date Date.current + 2.days
    enabled true

    initialize_with { new(start_date: start_date,
                          end_date: end_date,
                          phase_enabled: enabled) }
    trait :publication do
      end_date nil
    end

    trait :past_start_date do
      start_date Date.current - 2.days
    end

    trait :past_end_date do
      end_date Date.current - 1.day
    end
  end

  factory :legislation_draft_version, class: 'Legislation::DraftVersion' do
    process factory: :legislation_process
    title "Version 1"
    changelog "What changed in this version"
    status "draft"
    final_version false
    body <<-LOREM_IPSUM
Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi.

Expetenda tincidunt in sed, ex partem placerat sea, porro commodo ex eam. His putant aeterno interesset at. Usu ea mundi tincidunt, omnium virtute aliquando ius ex. Ea aperiri sententiae duo. Usu nullam dolorum quaestio ei, sit vidit facilisis ea. Per ne impedit iracundia neglegentur. Consetetur neglegentur eum ut, vis animal legimus inimicus id.

His audiam deserunt in, eum ubique voluptatibus te. In reque dicta usu. Ne rebum dissentiet eam, vim omnis deseruisse id. Ullum deleniti vituperata at quo, insolens complectitur te eos, ea pri dico munere propriae. Vel ferri facilis ut, qui paulo ridens praesent ad. Possim alterum qui cu. Accusamus consulatu ius te, cu decore soleat appareat usu.

Est ei erat mucius quaeque. Ei his quas phaedrum, efficiantur mediocritatem ne sed, hinc oratio blandit ei sed. Blandit gloriatur eam et. Brute noluisse per et, verear disputando neglegentur at quo. Sea quem legere ei, unum soluta ne duo. Ludus complectitur quo te, ut vide autem homero pro.

Vis id minim dicant sensibus. Pri aliquip conclusionemque ad, ad malis evertitur torquatos his. Has ei solum harum reprimique, id illum saperet tractatos his. Ei omnis soleat antiopam quo. Ad augue inani postulant mel, mel ea qualisque forensibus.

Lorem salutandi eu mea, eam in soleat iriure assentior. Tamquam lobortis id qui. Ea sanctus democritum mei, per eu alterum electram adversarium. Ea vix probo dicta iuvaret, posse epicurei suavitate eam an, nam et vidit menandri. Ut his accusata petentium.
LOREM_IPSUM

    trait :published do
      status "published"
    end

    trait :final_version do
      final_version true
    end
  end

  factory :legislation_annotation, class: 'Legislation::Annotation' do
    draft_version factory: :legislation_draft_version
    author factory: :user
    quote "ipsum"
    text "a comment"
    ranges [{"start" => "/p[1]", "startOffset" => 6, "end" => "/p[1]", "endOffset" => 11}]
    range_start "/p[1]"
    range_start_offset 6
    range_end "/p[1]"
    range_end_offset 11
  end

  factory :legislation_question, class: 'Legislation::Question' do
    process factory: :legislation_process
    title "Question text"
    author factory: :user
  end

  factory :legislation_question_option, class: 'Legislation::QuestionOption' do
    question factory: :legislation_question
    sequence(:value) { |n| "Option #{n}" }
  end

  factory :legislation_answer, class: 'Legislation::Answer' do
    question factory: :legislation_question
    question_option factory: :legislation_question_option
    user
  end

  factory :site_customization_page, class: 'SiteCustomization::Page' do
    slug "example-page"
    title "Example page"
    subtitle "About an example"
    content "This page is about..."
    more_info_flag false
    print_content_flag false
    status 'draft'
    locale 'en'

    trait :published do
      status "published"
    end

    trait :display_in_more_info do
      more_info_flag true
    end
  end

  factory :site_customization_content_block, class: 'SiteCustomization::ContentBlock' do
    name "top_links"
    locale "en"
    body "Some top links content"
  end

  factory :topic do
    sequence(:title) { |n| "Topic title #{n}" }
    sequence(:description) { |n| "Description as comment #{n}" }
    association :author, factory: :user
  end

  factory :direct_upload do
    user

    trait :proposal do
      resource_type "Proposal"
    end
    trait :budget_investment do
      resource_type "Budget::Investment"
    end

    trait :documents do
      resource_relation "documents"
      attachment { File.new("spec/fixtures/files/empty.pdf") }
    end
    trait :image do
      resource_relation "image"
      attachment { File.new("spec/fixtures/files/clippy.jpg") }
    end
    initialize_with { new(attributes) }
  end

  factory :map_location do
    latitude 51.48
    longitude 0.0
    zoom 10

    trait :proposal_map_location do
      proposal
    end

    trait :budget_investment_map_location do
      association :investment, factory: :budget_investment
    end
  end

end
