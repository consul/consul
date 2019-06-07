section "Creating collaborative legislation" do
  9.times do |i|
    Legislation::Process.create!(title: Faker::Lorem.sentence(3).truncate(60),
                                 description: Faker::Lorem.paragraphs.join("\n\n"),
                                 summary: Faker::Lorem.paragraph,
                                 additional_info: Faker::Lorem.paragraphs.join("\n\n"),
                                 proposals_description: Faker::Lorem.paragraph,
                                 start_date: Date.current + (i - 7).days,
                                 end_date: Date.current + (i - 1).days,
                                 debate_start_date: Date.current + (i - 7).days,
                                 debate_end_date: Date.current + (i - 5).days,
                                 proposals_phase_start_date: Date.current + (i - 7).days,
                                 proposals_phase_end_date: Date.current + (i - 5).days,
                                 draft_publication_date: Date.current + (i - 3).days,
                                 allegations_start_date: Date.current + (i - 2).days,
                                 allegations_end_date: Date.current + (i - 1).days,
                                 result_publication_date: Date.current + i.days,
                                 debate_phase_enabled: true,
                                 allegations_phase_enabled: true,
                                 draft_publication_enabled: true,
                                 result_publication_enabled: true,
                                 proposals_phase_enabled: true,
                                 published: true,
                                 title_label: "Proposal title",
                                 summary_label: "Proposal summary",
                                 description_label: "Proposal text",
                                 video_url_label: "Link to external video",
                                 image_label: "Descriptive image",
                                 documents_label: "Documents",
                                 geozone_label: "Scope of operation",
                                 tags_label: "Categories")
  end

  Legislation::Process.find_each do |process|
    (1..3).each do |i|
      process.draft_versions.create!(title_en: "Version #{i}",
                                     title_es: "Versión #{i}",
                                     body_en: ["Draft version in English",
                                               *Faker::Lorem.paragraphs].join("\n\n"),
                                     body_es: ["Versión borrador en Español",
                                               *Faker::Lorem.paragraphs].join("\n\n"))
    end
  end
end
