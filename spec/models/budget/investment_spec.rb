require "rails_helper"

describe Budget::Investment do
  let(:investment) { build(:budget_investment) }

  describe "Concerns" do
    it_behaves_like "notifiable"
  end

  it "is valid" do
    expect(investment).to be_valid
  end

  it "is not valid without an author" do
    investment.author = nil
    expect(investment).not_to be_valid
  end

  describe "#title" do
    it "is not valid without a title" do
      investment.title = nil
      expect(investment).not_to be_valid
    end

    it "is not valid when very short" do
      investment.title = "abc"
      expect(investment).not_to be_valid
    end

    it "is not valid when very long" do
      investment.title = "a" * 81
      expect(investment).not_to be_valid
    end
  end

  it_behaves_like "acts as imageable", "budget_investment_image"

  it "sanitizes description" do
    investment.description = "<script>alert('danger');</script>"
    investment.valid?
    expect(investment.description).to eq("alert('danger');")
  end

  it "set correct group and budget ids" do
    budget = create(:budget)
    group_1 = create(:budget_group, budget: budget)
    group_2 = create(:budget_group, budget: budget)

    heading_1 = create(:budget_heading, group: group_1)
    heading_2 = create(:budget_heading, group: group_2)

    investment = create(:budget_investment, heading: heading_1)

    expect(investment.budget_id).to eq budget.id
    expect(investment.group_id).to eq group_1.id

    investment.update(heading: heading_2)

    expect(investment.budget_id).to eq budget.id
    expect(investment.group_id).to eq group_2.id
  end

  describe "#unfeasibility_explanation blank" do
    it "is valid if valuation not finished" do
      investment.unfeasibility_explanation = ""
      investment.valuation_finished = false
      expect(investment).to be_valid
    end

    it "is valid if valuation finished and feasible" do
      investment.unfeasibility_explanation = ""
      investment.feasibility = "feasible"
      investment.valuation_finished = true
      expect(investment).to be_valid
    end

    it "is not valid if valuation finished and unfeasible" do
      investment.unfeasibility_explanation = ""
      investment.feasibility = "unfeasible"
      investment.valuation_finished = true
      expect(investment).not_to be_valid
    end
  end

  describe "#price blank" do
    it "is valid if valuation not finished" do
      investment.price = ""
      investment.valuation_finished = false
      expect(investment).to be_valid
    end

    it "is valid if valuation finished and unfeasible" do
      investment.price = ""
      investment.unfeasibility_explanation = "reason"
      investment.feasibility = "unfeasible"
      investment.valuation_finished = true
      expect(investment).to be_valid
    end

    it "is not valid if valuation finished and feasible" do
      investment.price = ""
      investment.feasibility = "feasible"
      investment.valuation_finished = true
      expect(investment).not_to be_valid
    end
  end

  describe "#code" do
    let(:investment) { create(:budget_investment) }

      it "returns the proposal id" do
        expect(investment.code).to include(investment.id.to_s)
      end

      it "returns the administrator id when assigned" do
        investment.administrator = create(:administrator)
        expect(investment.code).to include("#{investment.id}-A#{investment.administrator.id}")
      end
  end

  describe "#send_unfeasible_email" do
    let(:investment) { create(:budget_investment) }

    it "sets the time when the unfeasible email was sent" do
      expect(investment.unfeasible_email_sent_at).not_to be
      investment.send_unfeasible_email
      expect(investment.unfeasible_email_sent_at).to be
    end

    it "send an email" do
      expect {investment.send_unfeasible_email}.to change { ActionMailer::Base.deliveries.count }.by(1)
    end
  end

  describe "#should_show_votes?" do
    it "returns true in selecting phase" do
      budget = create(:budget, phase: "selecting")
      investment = create(:budget_investment, budget: budget)

      expect(investment.should_show_votes?).to eq(true)
    end

    it "returns false in any other phase" do
      Budget::Phase::PHASE_KINDS.reject {|phase| phase == "selecting"}.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, budget: budget)

        expect(investment.should_show_votes?).to eq(false)
      end
    end
  end

  describe "#should_show_vote_count?" do
    it "returns true in valuating phase" do
      budget = create(:budget, phase: "valuating")
      investment = create(:budget_investment, budget: budget)

      expect(investment.should_show_vote_count?).to eq(true)
    end

    it "returns false in any other phase" do
      Budget::Phase::PHASE_KINDS.reject {|phase| phase == "valuating"}.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, budget: budget)

        expect(investment.should_show_vote_count?).to eq(false)
      end
    end
  end

  describe "#should_show_ballots?" do
    it "returns true in balloting phase for selected investments" do
      budget = create(:budget, phase: "balloting")
      investment = create(:budget_investment, :selected, budget: budget)

      expect(investment.should_show_ballots?).to eq(true)
    end

    it "returns false for unselected investments" do
      budget = create(:budget, phase: "balloting")
      investment = create(:budget_investment, :unselected, budget: budget)

      expect(investment.should_show_ballots?).to eq(false)
    end

    it "returns false in any other phase" do
      Budget::Phase::PHASE_KINDS.reject {|phase| phase == "balloting"}.each do |phase|
        budget = create(:budget, phase: phase)
        investment = create(:budget_investment, :selected, budget: budget)

        expect(investment.should_show_ballots?).to eq(false)
      end
    end
  end

  describe "#should_show_price?" do
    let(:budget) { create(:budget, :publishing_prices) }
    let(:investment) do
      create(:budget_investment, :selected, budget: budget)
    end

    it "returns true for selected investments which budget's phase is publishing_prices or later" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_price?).to eq(true)
      end
    end

    it "returns false in any other phase" do
      (Budget::Phase::PHASE_KINDS - Budget::Phase::PUBLISHED_PRICES_PHASES).each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_price?).to eq(false)
      end
    end

    it "returns false if investment is not selected" do
      investment.selected = false

      expect(investment.should_show_price?).to eq(false)
    end

    it "returns false if price is not present" do
      investment.price = nil

      expect(investment.should_show_price?).to eq(false)
    end
  end

  describe "#should_show_price_explanation?" do
    let(:budget) { create(:budget, :publishing_prices) }
    let(:investment) do
      create(:budget_investment, :selected, budget: budget, price_explanation: "because of reasons")
    end

    it "returns true for selected with price_explanation & budget in publishing_prices or later" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_price_explanation?).to eq(true)
      end
    end

    it "returns false in any other phase" do
      (Budget::Phase::PHASE_KINDS - Budget::Phase::PUBLISHED_PRICES_PHASES).each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_price_explanation?).to eq(false)
      end
    end

    it "returns false if investment is not selected" do
      investment.selected = false

      expect(investment.should_show_price_explanation?).to eq(false)
    end

    it "returns false if price_explanation is not present" do
      investment.price_explanation = ""

      expect(investment.should_show_price_explanation?).to eq(false)
    end
  end

  describe "#should_show_unfeasibility_explanation?" do
    let(:budget) { create(:budget) }
    let(:investment) do
      create(:budget_investment, budget: budget,
             unfeasibility_explanation: "because of reasons",
             valuation_finished: true,
             feasibility: "unfeasible")
    end

    it "returns true for unfeasible investments with unfeasibility explanation and valuation finished" do
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(true)
      end
    end

    it "returns false in valuation has not finished" do
      investment.update(valuation_finished: false)
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(false)
      end
    end

    it "returns false if not unfeasible" do
      investment.update(feasibility: "undecided")
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(false)
      end
    end

    it "returns false if unfeasibility explanation blank" do
      investment.update(unfeasibility_explanation: "")
      Budget::Phase::PUBLISHED_PRICES_PHASES.each do |phase|
        budget.update(phase: phase)

        expect(investment.should_show_unfeasibility_explanation?).to eq(false)
      end
    end
  end

  describe "#by_budget" do

    it "returns investments scoped by budget" do
       budget1 = create(:budget)
       budget2 = create(:budget)

       group1 = create(:budget_group, budget: budget1)
       group2 = create(:budget_group, budget: budget2)

       heading1 = create(:budget_heading, group: group1)
       heading2 = create(:budget_heading, group: group2)

       investment1 = create(:budget_investment, heading: heading1)
       investment2 = create(:budget_investment, heading: heading1)
       investment3 = create(:budget_investment, heading: heading2)

       investments_by_budget = Budget::Investment.by_budget(budget1)

       expect(investments_by_budget).to include investment1
       expect(investments_by_budget).to include investment2
       expect(investments_by_budget).not_to include investment3
    end
  end

  describe "#by_admin" do
    it "returns investments assigned to specific administrator" do
      investment1 = create(:budget_investment, administrator_id: 33)
      create(:budget_investment)

      by_admin = described_class.by_admin(33)

      expect(by_admin.size).to eq(1)
      expect(by_admin.first).to eq(investment1)
    end
  end

  describe "by_valuator" do
    it "returns investments assigned to specific valuator" do
      investment1 = create(:budget_investment)
      investment2 = create(:budget_investment)
      investment3 = create(:budget_investment)

      valuator1 = create(:valuator)
      valuator2 = create(:valuator)

      investment1.valuators << valuator1
      investment2.valuators << valuator2
      investment3.valuators << [valuator1, valuator2]

      by_valuator = described_class.by_valuator(valuator1.id)

      expect(by_valuator.size).to eq(2)
      expect(by_valuator.sort).to eq([investment1, investment3].sort)
    end
  end

  describe "#by_valuator_group" do

    it "returns investments assigned to a valuator's group" do
      valuator = create(:valuator)
      valuator_group = create(:valuator_group, valuators: [valuator])
      assigned_investment = create(:budget_investment, valuators: [valuator],
                                                       valuator_groups: [valuator_group])
      another_assigned_investment = create(:budget_investment, valuator_groups: [valuator_group])
      unassigned_investment = create(:budget_investment, valuators: [valuator], valuator_groups: [])
      create(:budget_investment, valuators: [valuator], valuator_groups: [create(:valuator_group)])

      by_valuator_group = described_class.by_valuator_group(valuator.valuator_group_id)

      expect(by_valuator_group.size).to eq(2)
      expect(by_valuator_group).to contain_exactly(assigned_investment, another_assigned_investment)
    end
  end

  describe "scoped_filter" do

    let!(:budget)     { create(:budget, slug: "budget_slug") }
    let!(:group)      { create(:budget_group, budget: budget) }
    let!(:heading)    { create(:budget_heading, group: group) }
    let!(:investment) { create(:budget_investment, :feasible, heading: heading) }

    it "finds budget by id or slug" do
      result = described_class.scoped_filter({budget_id: budget.id}, nil)
      expect(result.count).to be 1
      expect(result.first.id).to be investment.id

      result = described_class.scoped_filter({budget_id: "budget_slug"}, nil)
      expect(result.count).to be 1
      expect(result.first.id).to be investment.id
    end

    it "does not raise error if budget is not found" do
      result = described_class.scoped_filter({budget_id: "wrong_budget"}, nil)
      expect(result).to be_empty
    end

  end

  describe "scopes" do
    describe "valuation_open" do
      it "returns all investments with false valuation_finished" do
        investment1 = create(:budget_investment, valuation_finished: true)
        investment2 = create(:budget_investment)

        valuation_open = described_class.valuation_open

        expect(valuation_open.size).to eq(1)
        expect(valuation_open.first).to eq(investment2)
      end
    end

    describe "without_admin" do
      it "returns all open investments without assigned admin" do
        investment1 = create(:budget_investment, valuation_finished: true)
        investment2 = create(:budget_investment, administrator: create(:administrator))
        investment3 = create(:budget_investment)

        without_admin = described_class.without_admin

        expect(without_admin.size).to eq(1)
        expect(without_admin.first).to eq(investment3)
      end
    end

    describe "managed" do
      it "returns all open investments with assigned admin but without assigned valuators" do
        investment1 = create(:budget_investment, administrator: create(:administrator))
        investment2 = create(:budget_investment, administrator: create(:administrator), valuation_finished: true)
        investment3 = create(:budget_investment, administrator: create(:administrator))
        investment1.valuators << create(:valuator)

        managed = described_class.managed

        expect(managed.size).to eq(1)
        expect(managed.first).to eq(investment3)
      end
    end

    describe "valuating" do
      it "returns all investments with assigned valuator but valuation not finished" do
        investment1 = create(:budget_investment)
        investment2 = create(:budget_investment)
        investment3 = create(:budget_investment, valuation_finished: true)

        investment2.valuators << create(:valuator)
        investment3.valuators << create(:valuator)

        valuating = described_class.valuating

        expect(valuating.size).to eq(1)
        expect(valuating.first).to eq(investment2)
      end

      it "returns all investments with assigned valuator groups but valuation not finished" do
        investment1 = create(:budget_investment)
        investment2 = create(:budget_investment)
        investment3 = create(:budget_investment, valuation_finished: true)

        investment2.valuator_groups << create(:valuator_group)
        investment3.valuator_groups << create(:valuator_group)

        valuating = described_class.valuating

        expect(valuating.size).to eq(1)
        expect(valuating.first).to eq(investment2)
      end
    end

    describe "valuation_finished" do
      it "returns all investments with valuation finished" do
        investment1 = create(:budget_investment)
        investment2 = create(:budget_investment)
        investment3 = create(:budget_investment, valuation_finished: true)

        investment2.valuators << create(:valuator)
        investment3.valuators << create(:valuator)

        valuation_finished = described_class.valuation_finished

        expect(valuation_finished.size).to eq(1)
        expect(valuation_finished.first).to eq(investment3)
      end
    end

    describe "feasible" do
      it "returns all feasible investments" do
        feasible_investment = create(:budget_investment, :feasible)
        create(:budget_investment)

        expect(described_class.feasible).to eq [feasible_investment]
      end
    end

    describe "unfeasible" do
      it "returns all unfeasible investments" do
        unfeasible_investment = create(:budget_investment, :unfeasible)
        create(:budget_investment, :feasible)

        expect(described_class.unfeasible).to eq [unfeasible_investment]
      end
    end

    describe "not_unfeasible" do
      it "returns all feasible and undecided investments" do
        unfeasible_investment = create(:budget_investment, :unfeasible)
        undecided_investment = create(:budget_investment, :undecided)
        feasible_investment = create(:budget_investment, :feasible)

        expect(described_class.not_unfeasible.sort).to eq [undecided_investment, feasible_investment].sort
      end
    end

    describe "undecided" do
      it "returns all undecided investments" do
        unfeasible_investment = create(:budget_investment, :unfeasible)
        undecided_investment = create(:budget_investment, :undecided)
        feasible_investment = create(:budget_investment, :feasible)

        expect(described_class.undecided).to eq [undecided_investment]
      end
    end

    describe "selected" do
      it "returns all selected investments" do
        selected_investment = create(:budget_investment, :selected)
        unselected_investment = create(:budget_investment, :unselected)

        expect(described_class.selected).to eq [selected_investment]
      end
    end

    describe "unselected" do
      it "returns all unselected not_unfeasible investments" do
        selected_investment = create(:budget_investment, :selected)
        unselected_unfeasible_investment = create(:budget_investment, :unselected, :unfeasible)
        unselected_undecided_investment = create(:budget_investment, :unselected, :undecided)
        unselected_feasible_investment = create(:budget_investment, :unselected, :feasible)

        expect(described_class.unselected.sort).to eq [unselected_undecided_investment, unselected_feasible_investment].sort
      end
    end
  end

  describe "apply_filters_and_search" do

    let(:budget) { create(:budget) }

    it "returns feasible investments" do
      investment1 = create(:budget_investment, :feasible,   budget: budget)
      investment2 = create(:budget_investment, :feasible,   budget: budget)
      investment3 = create(:budget_investment, :unfeasible, budget: budget)

      results = described_class.apply_filters_and_search(budget, {}, :feasible)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns unfeasible investments" do
      investment1 = create(:budget_investment, :unfeasible, budget: budget)
      investment2 = create(:budget_investment, :unfeasible, budget: budget)
      investment3 = create(:budget_investment, :feasible,   budget: budget)

      results = described_class.apply_filters_and_search(budget, {}, :unfeasible)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns selected investments" do
      budget.update(phase: "balloting")

      investment1 = create(:budget_investment, :feasible, :selected,   budget: budget)
      investment2 = create(:budget_investment, :feasible, :selected,   budget: budget)
      investment3 = create(:budget_investment, :feasible, :unselected, budget: budget)

      results = described_class.apply_filters_and_search(budget, {}, :selected)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns unselected investments" do
      budget.update(phase: "balloting")

      investment1 = create(:budget_investment, :feasible, :unselected, budget: budget)
      investment2 = create(:budget_investment, :feasible, :unselected, budget: budget)
      investment3 = create(:budget_investment, :feasible, :selected,   budget: budget)

      results = described_class.apply_filters_and_search(budget, {}, :unselected)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns investmens by heading" do
      group = create(:budget_group, budget: budget)

      heading1 = create(:budget_heading, group: group)
      heading2 = create(:budget_heading, group: group)

      investment1 = create(:budget_investment, heading: heading1, budget: budget)
      investment2 = create(:budget_investment, heading: heading1, budget: budget)
      investment3 = create(:budget_investment, heading: heading2, budget: budget)

      results = described_class.apply_filters_and_search(budget, heading_id: heading1.id)

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end

    it "returns investments by search string" do
      investment1 = create(:budget_investment, title: "health for all",  budget: budget)
      investment2 = create(:budget_investment, title: "improved health", budget: budget)
      investment3 = create(:budget_investment, title: "finance",         budget: budget)

      results = described_class.apply_filters_and_search(budget, search: "health")

      expect(results).to     include investment1
      expect(results).to     include investment2
      expect(results).not_to include investment3
    end
  end

  describe "search" do

    context "attributes" do

      it "searches by title" do
        budget_investment = create(:budget_investment, title: "save the world")
        results = described_class.search("save the world")
        expect(results).to eq([budget_investment])
      end

      it "searches by id" do
        budget_investment = create(:budget_investment, title: "free willy")
        results = described_class.search(budget_investment.id)
        expect(results).to eq([budget_investment])
      end

      it "searches by author name" do
        author = create(:user, username: "Danny Trejo")
        budget_investment = create(:budget_investment, author: author)
        results = described_class.search("Danny")
        expect(results).to eq([budget_investment])
      end

    end

    context "tags" do
      it "searches by tags" do
        investment = create(:budget_investment, tag_list: "Latina")

        results = described_class.search("Latina")
        expect(results.first).to eq(investment)

        results = described_class.search("Latin")
        expect(results.first).to eq(investment)
      end

      it "gets and sets valuation tags through virtual attributes" do
        investment = create(:budget_investment)

        investment.valuation_tag_list = %w[Code Test Refactor]

        expect(investment.valuation_tag_list).to match_array(%w[Code Test Refactor])
      end
    end

  end

  describe "Permissions" do
    let(:budget)      { create(:budget) }
    let(:group)       { create(:budget_group, budget: budget) }
    let(:heading)     { create(:budget_heading, group: group) }
    let(:user)        { create(:user, :level_two) }
    let(:luser)       { create(:user) }
    let(:district_sp) { create(:budget_investment, budget: budget, group: group, heading: heading) }

    describe "#reason_for_not_being_selectable_by" do
      it "rejects not logged in users" do
        expect(district_sp.reason_for_not_being_selectable_by(nil)).to eq(:not_logged_in)
      end

      it "rejects not verified users" do
        expect(district_sp.reason_for_not_being_selectable_by(luser)).to eq(:not_verified)
      end

      it "rejects organizations" do
        create(:organization, user: user)
        expect(district_sp.reason_for_not_being_selectable_by(user)).to eq(:organization)
      end

      it "rejects selections when selecting is not allowed (via admin setting)" do
        budget.phase = "reviewing"
        expect(district_sp.reason_for_not_being_selectable_by(user)).to eq(:no_selecting_allowed)
      end

      it "accepts valid selections when selecting is allowed" do
        budget.phase = "selecting"
        expect(district_sp.reason_for_not_being_selectable_by(user)).to be_nil
      end

      it "rejects votes in two headings of the same group" do
        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        salamanca_investment   = create(:budget_investment, heading: salamanca)

        create(:vote, votable: carabanchel_investment, voter: user)

        expect(salamanca_investment.valid_heading?(user)).to eq(false)
      end

      it "accepts votes in multiple headings of the same group" do
        group.update(max_votable_headings: 2)

        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        salamanca_investment   = create(:budget_investment, heading: salamanca)

        create(:vote, votable: carabanchel_investment, voter: user)

        expect(salamanca_investment.valid_heading?(user)).to eq(true)
      end

      it "accepts votes in any heading previously voted in" do
        group.update(max_votable_headings: 2)

        carabanchel = create(:budget_heading, group: group)
        salamanca   = create(:budget_heading, group: group)

        carabanchel_investment = create(:budget_investment, heading: carabanchel)
        salamanca_investment   = create(:budget_investment, heading: salamanca)

        create(:vote, votable: carabanchel_investment, voter: user)
        create(:vote, votable: salamanca_investment, voter: user)

        expect(carabanchel_investment.valid_heading?(user)).to eq(true)
        expect(salamanca_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading" do
        all_city_investment = create(:budget_investment, heading: heading)
        expect(all_city_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading after voting in that heading" do
        all_city_investment1 = create(:budget_investment, heading: heading)
        all_city_investment2 = create(:budget_investment, heading: heading)

        create(:vote, votable: all_city_investment1, voter: user)

        expect(all_city_investment2.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with a single heading after voting in another group" do
        districts = create(:budget_group, budget: budget)
        carabanchel = create(:budget_heading, group: districts)

        all_city_investment    = create(:budget_investment, heading: heading)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)

        create(:vote, votable: carabanchel_investment, voter: user)

        expect(all_city_investment.valid_heading?(user)).to eq(true)
      end

      it "allows votes in a group with multiple headings after voting in group with a single heading" do
        districts = create(:budget_group, budget: budget)
        carabanchel = create(:budget_heading, group: districts)
        salamanca   = create(:budget_heading, group: districts)

        all_city_investment    = create(:budget_investment, heading: heading)
        carabanchel_investment = create(:budget_investment, heading: carabanchel)

        create(:vote, votable: all_city_investment, voter: user)

        expect(carabanchel_investment.valid_heading?(user)).to eq(true)
      end

      describe "#can_vote_in_another_heading?" do

        let(:districts)   { create(:budget_group, budget: budget) }
        let(:carabanchel) { create(:budget_heading, group: districts) }
        let(:salamanca)   { create(:budget_heading, group: districts) }
        let(:latina)      { create(:budget_heading, group: districts) }

        let(:carabanchel_investment) { create(:budget_investment, heading: carabanchel) }
        let(:salamanca_investment)   { create(:budget_investment, heading: salamanca) }
        let(:latina_investment)      { create(:budget_investment, heading: latina) }

        it "returns true if the user has voted in less headings than the maximum" do
          districts.update(max_votable_headings: 2)

          create(:vote, votable: carabanchel_investment, voter: user)

          expect(salamanca_investment.can_vote_in_another_heading?(user)).to eq(true)
        end

        it "returns false if the user has already voted in the maximum number of headings" do
          districts.update(max_votable_headings: 2)

          create(:vote, votable: carabanchel_investment, voter: user)
          create(:vote, votable: salamanca_investment, voter: user)

          expect(latina_investment.can_vote_in_another_heading?(user)).to eq(false)
        end
      end
    end
  end

  describe "#headings_voted_by_user" do
    it "returns the headings voted by a user" do
      user1 = create(:user)
      user2 = create(:user)

      budget = create(:budget)
      group = create(:budget_group, budget: budget)

      new_york = create(:budget_heading, group: group)
      san_franciso = create(:budget_heading, group: group)
      another_heading = create(:budget_heading, group: group)

      new_york_investment = create(:budget_investment, heading: new_york)
      san_franciso_investment = create(:budget_investment, heading: san_franciso)
      another_investment = create(:budget_investment, heading: san_franciso)

      create(:vote, votable: new_york_investment, voter: user1)
      create(:vote, votable: san_franciso_investment, voter: user1)

      expect(another_investment.headings_voted_by_user(user1)).to include(new_york.id)
      expect(another_investment.headings_voted_by_user(user1)).to include(san_franciso.id)
      expect(another_investment.headings_voted_by_user(user1)).not_to include(another_heading.id)

      expect(another_investment.headings_voted_by_user(user2)).not_to include(new_york.id)
      expect(another_investment.headings_voted_by_user(user2)).not_to include(san_franciso.id)
      expect(another_investment.headings_voted_by_user(user2)).not_to include(another_heading.id)
    end
  end

  describe "#voted_in?" do

    let(:user) { create(:user) }
    let(:investment) { create(:budget_investment) }

    it "returns true if the user has voted in this heading" do
      create(:vote, votable: investment, voter: user)

      expect(investment.voted_in?(investment.heading, user)).to eq(true)
    end

    it "returns false if the user has not voted in this heading" do
      expect(investment.voted_in?(investment.heading, user)).to eq(false)
    end

  end

  describe "Order" do
    describe "#sort_by_confidence_score" do

      it "orders by confidence_score" do
        least_voted = create(:budget_investment, cached_votes_up: 1)
        most_voted = create(:budget_investment, cached_votes_up: 10)
        some_votes = create(:budget_investment, cached_votes_up: 5)

        expect(described_class.sort_by_confidence_score.first).to eq most_voted
        expect(described_class.sort_by_confidence_score.second).to eq some_votes
        expect(described_class.sort_by_confidence_score.third).to eq least_voted
      end

      it "orders by confidence_score and then by id" do
        least_voted  = create(:budget_investment, cached_votes_up: 1)
        most_voted   = create(:budget_investment, cached_votes_up: 10)
        most_voted2  = create(:budget_investment, cached_votes_up: 10)
        least_voted2 = create(:budget_investment, cached_votes_up: 1)

        expect(described_class.sort_by_confidence_score.first).to eq most_voted2
        expect(described_class.sort_by_confidence_score.second).to eq most_voted
        expect(described_class.sort_by_confidence_score.third).to eq least_voted2
        expect(described_class.sort_by_confidence_score.fourth).to eq least_voted
      end
    end
  end

  describe "responsible_name" do
    let(:user) { create(:user, document_number: "123456") }
    let!(:investment) { create(:budget_investment, author: user) }

    it "gets updated with the document_number" do
      expect(investment.responsible_name).to eq("123456")
    end

    it "does not get updated if the user is erased" do
      user.erase
      user.update(document_number: nil)
      expect(user.document_number).to be_blank
      investment.touch
      expect(investment.responsible_name).to eq("123456")
    end
  end

  describe "total votes" do
    it "takes into account physical votes in addition to web votes" do
      b = create(:budget, :selecting)
      g = create(:budget_group, budget: b)
      h = create(:budget_heading, group: g)
      i = create(:budget_investment, budget: b, group: g, heading: h)

      i.register_selection(create(:user, :level_two))
      expect(i.total_votes).to eq(1)

      i.physical_votes = 10
      expect(i.total_votes).to eq(11)
    end
  end

  describe "#with_supports" do
    it "returns proposals with supports" do
      inv1 = create(:budget_investment)
      inv2 = create(:budget_investment)
      create(:vote, votable: inv1)

      expect(described_class.with_supports).to include(inv1)
      expect(described_class.with_supports).not_to include(inv2)
    end
  end

  describe "Final Voting" do

    describe "Permissions" do
      let(:budget)      { create(:budget) }
      let(:group)       { create(:budget_group, budget: budget) }
      let(:heading)     { create(:budget_heading, group: group) }
      let(:user)        { create(:user, :level_two) }
      let(:luser)       { create(:user) }
      let(:ballot)      { create(:budget_ballot, budget: budget) }
      let(:investment)  { create(:budget_investment, :selected, budget: budget, heading: heading) }

      describe "#reason_for_not_being_ballotable_by" do
        it "rejects not logged in users" do
          expect(investment.reason_for_not_being_ballotable_by(nil, ballot)).to eq(:not_logged_in)
        end

        it "rejects not verified users" do
          expect(investment.reason_for_not_being_ballotable_by(luser, ballot)).to eq(:not_verified)
        end

        it "rejects organizations" do
          create(:organization, user: user)
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:organization)
        end

        it "rejects votes when voting is not allowed (wrong phase)" do
          budget.phase = "reviewing"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:no_ballots_allowed)
        end

        it "rejects non-selected investments" do
          investment.selected = false
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_selected)
        end

        it "accepts valid ballots when voting is allowed" do
          budget.phase = "balloting"
          expect(investment.reason_for_not_being_ballotable_by(user, ballot)).to be_nil
        end

        it "accepts valid selections" do
          budget.phase = "selecting"
          expect(investment.reason_for_not_being_selectable_by(user)).to be_nil
        end

        it "rejects users with different headings" do
          budget.phase = "balloting"
          group = create(:budget_group, budget: budget)
          california = create(:budget_heading, group: group)
          new_york = create(:budget_heading, group: group)

          inv1 = create(:budget_investment, :selected, budget: budget, group: group, heading: california)
          inv2 = create(:budget_investment, :selected, budget: budget, group: group, heading: new_york)
          ballot = create(:budget_ballot, user: user, budget: budget)
          ballot.investments << inv1

          expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:different_heading_assigned_html)
        end

        it "rejects proposals with price higher than current available money" do
          budget.phase = "balloting"
          districts = create(:budget_group, budget: budget)
          carabanchel = create(:budget_heading, group: districts, price: 35)
          inv1 = create(:budget_investment, :selected, budget: budget, group: districts, heading: carabanchel, price: 30)
          inv2 = create(:budget_investment, :selected, budget: budget, group: districts, heading: carabanchel, price: 10)

          ballot = create(:budget_ballot, user: user, budget: budget)
          ballot.investments << inv1

          expect(inv2.reason_for_not_being_ballotable_by(user, ballot)).to eq(:not_enough_money_html)
        end

      end

    end

  end

  describe "Reclassification" do

    let(:budget)   { create(:budget, phase: "balloting")   }
    let(:group)    { create(:budget_group, budget: budget) }
    let(:heading1) { create(:budget_heading, group: group) }
    let(:heading2) { create(:budget_heading, group: group) }

    describe "heading_changed?" do

      it "returns true if budget is in balloting phase and heading has changed" do
        investment = create(:budget_investment, heading: heading1)
        investment.heading = heading2

        expect(investment.heading_changed?).to eq(true)
      end

      it "returns false if heading has not changed" do
        investment = create(:budget_investment)
        investment.heading = investment.heading

        expect(investment.heading_changed?).to eq(false)
      end

      it "returns false if budget is not balloting phase" do
        Budget::Phase::PHASE_KINDS.reject {|phase| phase == "balloting"}.each do |phase|
          budget.update(phase: phase)
          investment = create(:budget_investment, budget: budget)

          investment.heading = heading2

          expect(investment.heading_changed?).to eq(false)
        end
      end

    end

    describe "log_heading_change" do

      it "stores the previous heading before being reclassified" do
        investment = create(:budget_investment, heading: heading1)

        expect(investment.heading_id).to eq(heading1.id)
        expect(investment.previous_heading_id).to eq(nil)

        investment.heading = heading2
        investment.save

        investment.reload
        expect(investment.heading_id).to eq(heading2.id)
        expect(investment.previous_heading_id).to eq(heading1.id)
      end

    end

    describe "store_reclassified_votes" do

      it "stores the votes for a reclassified investment" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times do
          ballot = create(:budget_ballot, budget: budget)
          ballot.investments << investment
        end

        expect(investment.ballot_lines_count).to eq(3)

        investment.heading = heading2
        investment.store_reclassified_votes("heading_changed")

        reclassified_vote = Budget::ReclassifiedVote.first

        expect(Budget::ReclassifiedVote.count).to eq(3)
        expect(reclassified_vote.investment_id).to eq(investment.id)
        expect(reclassified_vote.user_id).to eq(Budget::Ballot.first.user.id)
        expect(reclassified_vote.reason).to eq("heading_changed")
      end
    end

    describe "remove_reclassified_votes" do

      it "removes votes from invesment" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times do
          ballot = create(:budget_ballot, budget: budget)
          ballot.investments << investment
        end

        expect(investment.ballot_lines_count).to eq(3)

        investment.heading = heading2
        investment.remove_reclassified_votes

        investment.reload
        expect(investment.ballot_lines_count).to eq(0)
      end

    end

    describe "check_for_reclassification" do

      it "stores reclassfied votes and removes actual votes if an investment has been reclassified" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times do
          ballot = create(:budget_ballot, budget: budget)
          ballot.investments << investment
        end

        expect(investment.ballot_lines_count).to eq(3)

        investment.heading = heading2
        investment.save
        investment.reload

        expect(investment.ballot_lines_count).to eq(0)
        expect(Budget::ReclassifiedVote.count).to eq(3)
      end

      it "does not store reclassified votes nor remove actual votes if the investment has not been reclassifed" do
        investment = create(:budget_investment, :selected, heading: heading1)

        3.times do
          ballot = create(:budget_ballot, budget: budget)
          ballot.investments << investment
        end

        expect(investment.ballot_lines_count).to eq(3)

        investment.save
        investment.reload

        expect(investment.ballot_lines_count).to eq(3)
        expect(Budget::ReclassifiedVote.count).to eq(0)
      end

    end

  end

  describe "scoped_filter" do
    let(:budget)   { create(:budget, phase: "balloting")   }
    let(:investment) { create(:budget_investment, budget: budget) }

    describe "with without_admin filter" do
      let(:params) { {advanced_filters: ["without_admin"], budget_id: budget.id} }
      it "returns only investment without admin" do
        create(:budget_investment,
          :finished,
          budget: budget)
        create(:budget_investment,
          :with_administrator,
          budget: budget)
        investment3 = create(:budget_investment, budget: budget)
        expect(described_class.scoped_filter(params, "all")).to eq([investment3])
        expect(described_class.scoped_filter(params, "all").count).to eq(1)
      end
    end

    describe "with without_valuator filter" do
      let(:params) { {advanced_filters: ["without_valuator"], budget_id: budget.id} }
      it "returns only investment without valuator" do
        create(:budget_investment,
          :finished,
          budget: budget)
        investment2 = create(:budget_investment,
          :with_administrator,
          budget: budget)
        investment3 = create(:budget_investment,
          budget: budget)
        expect(described_class.scoped_filter(params, "all"))
          .to contain_exactly(investment2, investment3)
        expect(described_class.scoped_filter(params, "all").count)
        .to eq(2)
      end
    end

    describe "with under_valuation filter" do
      let(:params) { {advanced_filters: ["under_valuation"], budget_id: budget.id} }
      it "returns only investment under valuation" do
        valuator1 = create(:valuator)
        investment1 = create(:budget_investment,
          :with_administrator,
          valuation_finished: false,
          budget: budget)
        investment1.valuators << valuator1
        create(:budget_investment, :with_administrator, budget: budget)
        create(:budget_investment, budget: budget)

        expect(described_class.scoped_filter(params, "all")).to eq([investment1])
        expect(described_class.scoped_filter(params, "all").count).to eq(1)
      end
    end

    describe "with valuation_finished filter" do
      let(:params) { {advanced_filters: ["valuation_finished"], budget_id: budget.id} }
      it "returns only investment with valuation finished" do
        investment1 = create(:budget_investment,
          :selected,
          budget: budget)
        create(:budget_investment,
          :with_administrator,
          budget: budget)
        create(:budget_investment,
          budget: budget)
        expect(described_class.scoped_filter(params, "all")).to eq([investment1])
        expect(described_class.scoped_filter(params, "all").count).to eq(1)
      end
    end

    describe "with winners filter" do
      let(:params) { {advanced_filters: ["winners"], budget_id: budget.id} }
      it "returns only investment winners" do
        investment1 = create(:budget_investment,
          :winner,
          valuation_finished: true,
          budget: budget)
        create(:budget_investment,
          :with_administrator,
          budget: budget)
        create(:budget_investment, budget: budget)
        expect(described_class.scoped_filter(params, "all")).to eq([investment1])
        expect(described_class.scoped_filter(params, "all").count).to eq(1)
      end
    end
  end

  describe "admin_and_valuator_users_associated" do
    let(:investment) { create(:budget_investment) }
    let(:valuator_group) { create(:valuator_group) }
    let(:valuator) { create(:valuator) }
    let(:administrator) { create(:administrator) }

    it "returns empty array if not valuators or administrator assigned" do
      expect(investment.admin_and_valuator_users_associated).to eq([])
    end

    it "returns all valuator and administrator users" do
      valuator_group.valuators << valuator
      investment.valuator_groups << valuator_group
      expect(investment.admin_and_valuator_users_associated).to eq([valuator])
      investment.administrator = administrator
      expect(investment.admin_and_valuator_users_associated).to eq([valuator, administrator])
    end

    it "returns uniq valuators or administrator users" do
      valuator_group.valuators << valuator
      investment.valuator_groups << valuator_group
      investment.valuators << valuator
      investment.administrator = administrator
      expect(investment.admin_and_valuator_users_associated).to eq([valuator, administrator])

    end
  end

  describe "milestone_tags" do
    context "without milestone_tags" do
      let(:investment) {create(:budget_investment)}

      it "do not have milestone_tags" do
        expect(investment.milestone_tag_list).to eq([])
        expect(investment.milestone_tags).to eq([])
      end

      it "add a new milestone_tag" do
        investment.milestone_tag_list = "tag1,tag2"

        expect(investment.milestone_tag_list).to eq(["tag1", "tag2"])
      end
    end

    context "with milestone_tags" do
      let(:investment) {create(:budget_investment, :with_milestone_tags)}

      it "has milestone_tags" do
        expect(investment.milestone_tag_list.count).to eq(1)
      end
    end
  end
end
