FactoryBot.define do
  factory :legislation_process, class: "Legislation::Process" do
    title "A collaborative legislation process"
    description "Description of the process"
    summary "Summary of the process"

    start_date { Date.current - 5.days }
    end_date { Date.current + 5.days }
    debate_start_date { Date.current - 5.days }
    debate_end_date { Date.current + 2.days }
    draft_publication_date { Date.current - 1.day }
    allegations_start_date { Date.current }
    allegations_end_date { Date.current + 3.days }
    proposals_phase_start_date { Date.current }
    proposals_phase_end_date { Date.current + 2.days }
    result_publication_date { Date.current + 5.days }
    debate_phase_enabled true
    allegations_phase_enabled true
    proposals_phase_enabled true
    draft_publication_enabled true
    result_publication_enabled true
    published true
    title_label "Proposal title"
    summary_label "Proposal summary"
    description_label "Proposal text"
    video_url_label "Link to external video"
    image_label "Descriptive image"
    documents_label "Documents"
    geozone_label "Scope of operation"
    tags_label "Categories"

    trait :past do
      start_date { Date.current - 12.days }
      end_date { Date.current - 2.days }
      debate_start_date { Date.current - 12.days }
      debate_end_date { Date.current - 9.days }
      draft_publication_date { Date.current - 8.days }
      allegations_start_date { Date.current - 8.days }
      allegations_end_date { Date.current - 4.days }
      result_publication_date { Date.current - 2.days }
    end

    trait :in_draft_phase do
      start_date { Date.current - 5.days }
      end_date { Date.current + 5.days }
      draft_start_date { Date.current - 2.days }
      draft_end_date { Date.current + 2.days }
      draft_phase_enabled true
    end

    trait :in_debate_phase do
      start_date { Date.current - 5.days }
      end_date { Date.current + 5.days }
      debate_start_date { Date.current - 5.days }
      debate_end_date { Date.current + 1.day }
      draft_publication_date { Date.current + 1.day }
      allegations_start_date { Date.current + 2.days }
      allegations_end_date { Date.current + 3.days }
      result_publication_date { Date.current + 5.days }
    end

    trait :in_proposals_phase do
      proposals_phase_start_date { Date.current - 1.day }
      proposals_phase_end_date { Date.current + 2.days }
      proposals_phase_enabled true
    end

    trait :upcoming_proposals_phase do
      proposals_phase_start_date { Date.current + 1.day }
      proposals_phase_end_date { Date.current + 2.days }
      proposals_phase_enabled true
    end

    trait :published do
      published true
    end

    trait :not_published do
      published false
    end

    trait :open do
      start_date { 1.week.ago }
      end_date   { 1.week.from_now }
    end

    trait :empty do
      start_date { Date.current - 5.days }
      end_date { Date.current + 5.days }
      debate_start_date nil
      debate_end_date nil
      draft_publication_date nil
      allegations_start_date nil
      allegations_end_date nil
      proposals_phase_start_date nil
      proposals_phase_end_date nil
      result_publication_date nil
      debate_phase_enabled false
      allegations_phase_enabled false
      proposals_phase_enabled false
      draft_publication_enabled false
      result_publication_enabled false
      published true
    end

  end

  factory :legislation_draft_version, class: "Legislation::DraftVersion" do
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

  factory :legislation_annotation, class: "Legislation::Annotation" do
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

  factory :legislation_question, class: "Legislation::Question" do
    process factory: :legislation_process
    title "Question text"
    author factory: :user
  end

  factory :legislation_question_option, class: "Legislation::QuestionOption" do
    question factory: :legislation_question
    sequence(:value) { |n| "Option #{n}" }
  end

  factory :legislation_answer, class: "Legislation::Answer" do
    question factory: :legislation_question
    question_option factory: :legislation_question_option
    user
  end

  factory :legislation_proposal, class: "Legislation::Proposal" do
    sequence(:title) { |n| "Proposal #{n} for a legislation" }
    summary "This law should include..."
    terms_of_service "1"
    process factory: :legislation_process
    author factory: :user
  end
end
