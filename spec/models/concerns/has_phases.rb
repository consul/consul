require 'spec_helper'

shared_examples_for "a class with phase" do |prefix, start_date_column, end_date_column, enabled_column|

  let!(:model) { described_class }
  let!(:model_factory) { model.to_s.underscore.gsub("/", "_").to_sym }

  let!(:sample_items) { { published: create(model_factory,
                                            start_date_column => Date.current - 1.day,
                                            end_date_column => Date.current + 1.day,
                                            enabled_column => true),
                          not_published: create(model_factory,
                                                start_date_column => Date.current - 1.day,
                                                end_date_column => Date.current + 1.day,
                                                enabled_column => false),
                          next: create(model_factory,
                                       start_date_column => Date.current + 1.day,
                                       end_date_column => Date.current + 2.days,
                                       enabled_column => true),
                          not_next: create(model_factory,
                                           start_date_column => Date.current - 1.day,
                                           end_date_column => Date.current + 1.day,
                                           enabled_column => true),
                          started: create(model_factory,
                                          start_date_column => Date.current - 1.day,
                                          end_date_column => Date.current + 1.day,
                                          enabled_column => true),
                          not_started: create(model_factory,
                                              start_date_column => Date.current + 1.day,
                                              end_date_column => Date.current + 2.days,
                                              enabled_column => true),
                          open: create(model_factory,
                                       start_date_column => Date.current - 1.day,
                                       end_date_column => Date.current + 1.day,
                                       enabled_column => true),
                          not_open: create(model_factory,
                                           start_date_column => Date.current + 1.day,
                                           end_date_column => Date.current + 2.days,
                                           enabled_column => true),
                          past: create(model_factory,
                                       start_date_column => Date.current - 2.days,
                                       end_date_column => Date.current - 1.day,
                                       enabled_column => true),
                          not_past: create(model_factory,
                                           start_date_column => Date.current + 1.day,
                                           end_date_column => Date.current + 2.days,
                                           enabled_column => true) } }

  context "Phase #{prefix}" do
    describe ".has_phase" do
      it "defines an instance method which returns an object of class Phase" do
        item = create(model_factory)

        phase = item.send(:"#{prefix}_phase")
        expect(phase.class.name).to eq("HasPhases::Phase")
      end

      context "dates validations" do
        it "is valid" do
          item = build(model_factory,
                       start_date_column => Date.current - 1.day,
                       end_date_column => Date.current + 1.day,
                       enabled_column => true)
          expect(item).to be_valid
        end

        it "is invalid if start date is present but end date is not" do
          item = build(model_factory,
                       start_date_column => Date.current,
                       end_date_column => nil)
          expect(item).to_not be_valid
          expect(item.errors.messages[end_date_column]).to include("can't be blank")
        end

        it "is invalid if end date is present but start date is not" do
          item = build(model_factory,
                       start_date_column => nil,
                       end_date_column => Date.current)
          expect(item).to_not be_valid
          expect(item.errors.messages[start_date_column]).to include("can't be blank")
        end

        it "is invalid if end date is before start date" do
          item = build(model_factory,
                       start_date_column => Date.current + 1.day,
                       end_date_column => Date.current - 1.day)
          expect(item).to_not be_valid
          expect(item.errors.messages[end_date_column]).to include(/must be on or after/)
        end

        it "is valid if end date is the same as start date" do
          item = build(model_factory,
                       start_date_column => Date.current - 1.day,
                       end_date_column => Date.current - 1.day)
          expect(item).to be_valid
        end
      end

      context "scopes" do
        %w(published next started open past).each do |scope|
          it "#{scope}" do
            expect(model.send(:"#{prefix}_#{scope}")).to include(sample_items[:"#{scope}"])
            expect(model.send(:"#{prefix}_#{scope}")).to_not include(sample_items[:"not_#{scope}"])
          end
        end
      end
    end
  end
end

shared_examples_for "a class with publication" do |prefix, start_date_column, enabled_column|

  let!(:model) { described_class }
  let!(:model_factory) { model.to_s.underscore.gsub("/", "_").to_sym }

  let!(:sample_items) { { published: create(model_factory,
                                            start_date_column => Date.current - 1.day,
                                            enabled_column => true),
                          not_published: create(model_factory,
                                                start_date_column => Date.current - 1.day,
                                                enabled_column => false),
                          next: create(model_factory,
                                       start_date_column => Date.current + 1.day,
                                       enabled_column => true),
                          not_next: create(model_factory,
                                           start_date_column => Date.current - 1.day,
                                           enabled_column => true),
                          started: create(model_factory,
                                          start_date_column => Date.current - 1.day,
                                          enabled_column => true),
                          not_started: create(model_factory,
                                              start_date_column => Date.current + 1.day,
                                              enabled_column => true) } }

  context "Publication phase #{prefix}" do
    describe ".has_phase" do
      it "defines an instance method which returns an object of class Phase" do
        item = create(model_factory)

        phase = item.send(:"#{prefix}_publication")
        expect(phase.class.name).to eq("HasPhases::Phase")
      end

      context "scopes" do
        %w(published next started).each do |scope|
          it "#{scope}" do
            expect(model.send(:"#{prefix}_#{scope}")).to include(sample_items[:"#{scope}"])
            expect(model.send(:"#{prefix}_#{scope}")).to_not include(sample_items[:"not_#{scope}"])
          end
        end
      end
    end
  end
end

