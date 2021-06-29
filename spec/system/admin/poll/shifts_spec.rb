require "rails_helper"

describe "Admin shifts", :admin do
  scenario "Show" do
    officer = create(:poll_officer)

    booth1 = create(:poll_booth)
    booth2 = create(:poll_booth)

    create(:poll_shift, officer: officer, booth: booth1, date: Date.current)
    create(:poll_shift, officer: officer, booth: booth2, date: Time.zone.tomorrow)

    visit new_admin_booth_shift_path(booth1)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content I18n.l(Date.current, format: :long)
    expect(page).to have_content officer.name
    expect(page).to have_content officer.email

    visit new_admin_booth_shift_path(booth2)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content I18n.l(Time.zone.tomorrow, format: :long)
    expect(page).to have_content officer.name
    expect(page).to have_content officer.email
  end

  scenario "Create Vote Collection Shift and Recount & Scrutiny Shift on same date" do
    create(:poll)
    poll = create(:poll, :current)
    booth = create(:poll_booth, polls: [poll, create(:poll, :expired)])
    officer = create(:poll_officer)
    vote_collection_dates = (Date.current..poll.ends_at.to_date).to_a.map { |date| I18n.l(date, format: :long) }
    recount_scrutiny_dates = (poll.ends_at.to_date..poll.ends_at.to_date + 1.week).to_a.map { |date| I18n.l(date, format: :long) }

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_content "This booth has no shifts"

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    expect(page).to have_select("shift_date_vote_collection_date", options: ["Select day", *vote_collection_dates])
    expect(page).not_to have_select("shift_date_recount_scrutiny_date")
    select I18n.l(Date.current, format: :long), from: "shift_date_vote_collection_date"
    click_button "Add shift"

    expect(page).to have_content "Shift added"

    within("#shifts") do
      expect(page).to have_css(".shift", count: 1)
      expect(page).to have_content(I18n.l(Date.current, format: :long))
      expect(page).to have_content("Collect Votes")
      expect(page).to have_content(officer.name)
    end

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".shift", count: 1)

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    select "Recount & Scrutiny", from: "shift_task"

    expect(page).to have_select("shift_date_recount_scrutiny_date", options: ["Select day", *recount_scrutiny_dates])
    expect(page).not_to have_select("shift_date_vote_collection_date")
    select I18n.l(poll.ends_at.to_date + 4.days, format: :long), from: "shift_date_recount_scrutiny_date"
    click_button "Add shift"

    expect(page).to have_content "Shift added"

    within("#shifts") do
      expect(page).to have_css(".shift", count: 2)
      expect(page).to have_content(I18n.l(poll.ends_at.to_date + 4.days, format: :long))
      expect(page).to have_content("Recount & Scrutiny")
      expect(page).to have_content(officer.name)
    end
  end

  scenario "Vote Collection Shift and Recount & Scrutiny Shift don't include already assigned dates to officer" do
    poll = create(:poll, :current)
    booth = create(:poll_booth, polls: [poll])
    officer = create(:poll_officer)

    create(:poll_shift, :vote_collection_task, officer: officer, booth: booth, date: Date.current)
    create(:poll_shift, :recount_scrutiny_task, officer: officer, booth: booth, date: Time.zone.tomorrow)

    vote_collection_dates = (Date.current..poll.ends_at.to_date).to_a
                                                                .reject { |date| date == Date.current }
                                                                .map { |date| I18n.l(date, format: :long) }
    recount_scrutiny_dates = (poll.ends_at.to_date..poll.ends_at.to_date + 1.week).to_a
                                                                                  .reject { |date| date == Time.zone.tomorrow }
                                                                                  .map { |date| I18n.l(date, format: :long) }

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".shift", count: 2)

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"

    expect(page).to have_select("shift_date_vote_collection_date", options: ["Select day", *vote_collection_dates])
    select "Recount & Scrutiny", from: "shift_task"
    expect(page).to have_select("shift_date_recount_scrutiny_date", options: ["Select day", *recount_scrutiny_dates])
  end

  scenario "Change option from Recount & Scrutinity to Collect Votes" do
    booth = create(:poll_booth)
    officer = create(:poll_officer)

    create(:poll_shift, :vote_collection_task, officer: officer, booth: booth)
    create(:poll_shift, :recount_scrutiny_task, officer: officer, booth: booth)

    visit new_admin_booth_shift_path(booth, officer_id: officer.id)

    select "Recount & Scrutiny", from: "shift_task"

    expect(page).to have_select("shift_date_recount_scrutiny_date", options: ["Select day"])

    select "Collect Votes", from: "shift_task"

    expect(page).to have_select("shift_date_vote_collection_date", options: ["Voting days ended"])
  end

  scenario "Error on create" do
    poll = create(:poll, :current)
    booth = create(:poll_booth, polls: [poll])
    officer = create(:poll_officer)

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_content "This booth has no shifts"

    fill_in "search", with: officer.email
    click_button "Search"
    click_link "Edit shifts"
    click_button "Add shift"

    expect(page).to have_content "A date must be selected"
  end

  scenario "Destroy" do
    poll = create(:poll, :current)
    booth = create(:poll_booth, polls: [poll])
    officer = create(:poll_officer)

    shift = create(:poll_shift, officer: officer, booth: booth)

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".shift", count: 1)
    within("#shift_#{shift.id}") do
      accept_confirm("Remove: Are you sure?") { click_link "Remove" }
    end

    expect(page).to have_content "Shift removed"
    expect(page).to have_css(".shift", count: 0)
  end

  scenario "Try to destroy with associated recount" do
    assignment = create(:poll_booth_assignment)
    officer_assignment = create(:poll_officer_assignment, booth_assignment: assignment)
    create(:poll_recount, booth_assignment: assignment, officer_assignment: officer_assignment)

    officer = officer_assignment.officer
    booth = assignment.booth
    shift = create(:poll_shift, officer: officer, booth: booth)

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".shift", count: 1)
    within("#shift_#{shift.id}") do
      accept_confirm("Remove: Are you sure?") { click_link "Remove" }
    end

    expect(page).not_to have_content "Shift removed"
    expect(page).to have_content "Shifts with associated results or recounts cannot be deleted"
    expect(page).to have_css(".shift", count: 1)
  end

  scenario "try to destroy with associated partial results" do
    assignment = create(:poll_booth_assignment)
    officer_assignment = create(:poll_officer_assignment, booth_assignment: assignment)
    create(:poll_partial_result,
           booth_assignment: assignment,
           officer_assignment: officer_assignment)

    officer = officer_assignment.officer
    booth = assignment.booth
    shift = create(:poll_shift, officer: officer, booth: booth)

    visit available_admin_booths_path

    within("#booth_#{booth.id}") do
      click_link "Manage shifts"
    end

    expect(page).to have_css(".shift", count: 1)
    within("#shift_#{shift.id}") do
      accept_confirm("Remove: Are you sure?") { click_link "Remove" }
    end

    expect(page).not_to have_content "Shift removed"
    expect(page).to have_content "Shifts with associated results or recounts cannot be deleted"
    expect(page).to have_css(".shift", count: 1)
  end

  scenario "Destroy an officer" do
    booth = create(:poll_booth)
    officer = create(:poll_officer)

    create(:poll_shift, officer: officer, booth: booth)
    officer.destroy!

    visit new_admin_booth_shift_path(booth)

    expect(page).to have_css(".shift", count: 1)
    expect(page).to have_content(officer.name)
    expect(page).to have_content(officer.email)
  end

  scenario "Empty" do
    booth = create(:poll_booth)

    visit new_admin_booth_shift_path(booth)

    expect(page).to have_content "This booth has no shifts"
  end
end
