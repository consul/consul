require 'rails_helper'

feature 'Voters' do

  let(:poll) { create(:poll, :current) }
  let(:booth) { create(:poll_booth) }
  let(:officer) { create(:poll_officer) }

  background do
    login_as(officer.user)
    create(:geozone, :in_census)
    create(:poll_shift, officer: officer, booth: booth, date: Date.current, task: :vote_collection)
    booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)
  end

  scenario "Can vote", :js do
    # officer_assignment = create(:poll_officer_assignment, officer: officer)
    # poll = officer_assignment.booth_assignment.poll

    # set_officing_booth(officer_assignment.booth)
    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name

    click_button "Confirm vote"

    expect(page).to have_content "Vote introduced!"
    expect(page).to_not have_button "Confirm vote"

    page.evaluate_script("window.location.reload()")
    expect(page).to have_content "Has already participated in this poll"
    expect(page).to_not have_button "Confirm vote"

    expect(Poll::Voter.last.officer_id).to eq(officer.id)
  end

  scenario "Already voted", :js do
    poll2 = create(:poll, :current)
    booth_assignment = create(:poll_booth_assignment, poll: poll2, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

    user = create(:user, :level_two)
    voter = create(:poll_voter, poll: poll, user: user)

    visit new_officing_voter_path(id: voter.user.id)

    within("#poll_#{poll.id}") do
      expect(page).to have_content "Has already participated in this poll"
      expect(page).to_not have_button "Confirm vote"
    end

    within("#poll_#{poll2.id}") do
      expect(page).to have_button "Confirm vote"
    end
  end

  scenario "Had already verified his residence, but is not level 2 yet", :js do
    user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
    expect(user).to_not be_level_two_verified

    visit root_path
    click_link "Sign out"
    login_through_form_as_officer(officer.user)

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name

    # user = create(:user, residence_verified_at: Time.current, document_type: "1", document_number: "12345678Z")
    # expect(user).to_not be_level_two_verified
    # poll = create(:poll_officer_assignment, officer: officer).booth_assignment.poll

    # visit root_path
    # click_link "Sign out"
    # login_through_form_as_officer(officer.user)

    # visit new_officing_residence_path
    # officing_verify_residence

    # expect(page).to have_content "Polls"
    # expect(page).to have_content poll.name
  end

  scenario "Display only current polls on which officer has a voting shift today, and user can answer", :js do
    poll_current = create(:poll, :current)
    second_booth = create(:poll_booth)
    booth_assignment = create(:poll_booth_assignment, poll: poll_current, booth: second_booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)
    create(:poll_shift, officer: officer, booth: second_booth, date: Date.current, task: :recount_scrutiny)
    create(:poll_shift, officer: officer, booth: second_booth, date: Date.tomorrow, task: :vote_collection)

    poll_expired = create(:poll, :expired)
    create(:poll_officer_assignment, officer: officer, booth_assignment: create(:poll_booth_assignment, poll: poll_expired, booth: booth))

    poll_incoming = create(:poll, :incoming)
    create(:poll_officer_assignment, officer: officer, booth_assignment: create(:poll_booth_assignment, poll: poll_incoming, booth: booth))

    poll_geozone_restricted_in = create(:poll, :current, geozone_restricted: true, geozones: [Geozone.first])
    booth_assignment = create(:poll_booth_assignment, poll: poll_geozone_restricted_in, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

    poll_geozone_restricted_out = create(:poll, :current, geozone_restricted: true, geozones: [create(:geozone, census_code: "02")])
    booth_assignment = create(:poll_booth_assignment, poll: poll_geozone_restricted_out, booth: booth)
    create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

    visit new_officing_residence_path
    officing_verify_residence

    expect(page).to have_content "Polls"
    expect(page).to have_content poll.name
    expect(page).not_to have_content poll_current.name
    expect(page).not_to have_content poll_expired.name
    expect(page).not_to have_content poll_incoming.name
    expect(page).to have_content poll_geozone_restricted_in.name
    expect(page).not_to have_content poll_geozone_restricted_out.name
  end

  xscenario "After voting, via nvotes or physical booth", :js do
     poll1 = create(:poll, geozone_restricted: false)
     poll2 = create(:poll, geozone_restricted: false)

     user = create(:user, :level_two)
     # We can not simulate the nvotes callback in selenium, so this covers
     # voting via officing - physical and tablet
     voter = create(:poll_voter, poll: poll1, user: user)

     use_physical_booth
     set_officing_booth
     validate_officer
     visit new_officing_voter_path(id: voter.user.id)

     within("#poll_#{poll1.id}") do
       expect(page).to have_content "Has already participated in this poll"
       expect(page).to_not have_button "Confirm vote"
     end

     within("#poll_#{poll2.id}") do
       expect(page).to have_button "Confirm vote"
     end

     login_as(user)
     visit poll_path(poll1)
     expect(page).to have_content "You already have participated in this poll."
     visit poll_path(poll2)
     expect(page).to_not have_content "You already have participated in this poll."
   end

   xscenario "Store officer and booth information", :js do
     user  = create(:user, :in_census, id: rand(9999999))
     poll1 = create(:poll, nvotes_poll_id: 128, name: "¿Quieres que XYZ sea aprobado?")
     poll2 = create(:poll, nvotes_poll_id: 136, name: "Pregunta de votación de prueba")

     booth = create(:poll_booth)

     ba1 = create(:poll_booth_assignment, poll: poll1, booth: booth )
     ba2 = create(:poll_booth_assignment, poll: poll2, booth: booth )
     oa1 = create(:poll_officer_assignment, officer: officer, booth_assignment: ba1, date: Date.current)
     oa2 = create(:poll_officer_assignment, officer: officer, booth_assignment: ba2, date: Date.current)

     set_officing_booth(booth)

     validate_officer
     visit new_officing_residence_path
     officing_verify_residence

     within("#poll_#{poll1.id}") do
       click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"
     end

     within("#poll_#{poll2.id}") do
       click_button "Confirm vote"

      expect(page).to have_content "Vote introduced!"
     end

     expect(Poll::Voter.count).to eq(2)

     voter1 = Poll::Voter.first

     expect(voter1.booth_assignment).to eq(ba1)
     expect(voter1.officer_assignment).to eq(oa1)

     voter2 = Poll::Voter.last
     expect(voter2.booth_assignment).to eq(ba2)
     expect(voter2.officer_assignment).to eq(oa2)
   end

   context "Booth type" do

     scenario "Physical booth", :js do
       poll = create(:poll)
       booth = create(:poll_booth, physical: true)

       booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
       officer_assignment = create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

       visit root_path
       click_link "Sign out"
       login_through_form_as_officer(officer.user)

       visit new_officing_residence_path
       officing_verify_residence

       expect(page).to     have_button "Confirm vote"
       expect(page).to_not have_link "Vote on tablet"
     end

     xscenario "Digital booth", :js do
       poll = create(:poll)
       booth = create(:poll_booth, physical: false)

       booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
       officer_assignment = create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

       visit root_path
       click_link "Sign out"
       login_through_form_as_officer(officer.user)

       visit new_officing_residence_path
       officing_verify_residence

       expect(page).to_not have_button "Confirm vote"
       expect(page).to     have_link "Vote on tablet"
     end

     xscenario "Digital booth (already voted)", :js do
       user = create(:user, :in_census)
       poll = create(:poll)

       create(:poll_voter, poll: poll, user: user)

       booth = create(:poll_booth, physical: false)
       booth_assignment = create(:poll_booth_assignment, poll: poll, booth: booth)
       officer_assignment = create(:poll_officer_assignment, officer: officer, booth_assignment: booth_assignment)

       visit root_path
       click_link "Sign out"
       login_through_form_as_officer(officer.user)

       visit new_officing_residence_path
       officing_verify_residence

       expect(page).to_not have_link "Vote on tablet"
       expect(page).to     have_content "Ya ha participado en todas las votaciones."
     end

   end

   xscenario "No officer assignment for a poll", :js do
     poll1 = create(:poll)
     poll2 = create(:poll)

     ba = create(:poll_booth_assignment, poll: poll1)
     oa = create(:poll_officer_assignment, officer: officer, booth_assignment: ba)

     visit root_path
     click_link "Sign out"
     login_through_form_as_officer(officer.user)

     visit new_officing_residence_path
     officing_verify_residence

     expect(page).to have_content poll1.name
     expect(page).to have_content poll2.name

     within("#poll_#{poll2.id}") do
       expect(page).to_not have_content "Vote introduced!"
     end
   end

end
