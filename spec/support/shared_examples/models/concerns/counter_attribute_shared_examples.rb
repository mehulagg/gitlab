# frozen_string_literal: true
require 'spec_helper'

shared_examples_for CounterAttribute do |counter_attributes|
  describe 'Associations' do
    it { is_expected.to have_many(:counter_events).class_name(counter_attribute_events_class.name) }
  end

  it 'captures the model for accessing the events' do
    expect(subject.class.counter_attribute_events_class).to eq(counter_attribute_events_class)
  end

  it 'captures the table where to save the events' do
    expect(subject.class.counter_attribute_events_table).to eq(counter_attribute_table_name)
  end

  it 'captures the foreign key to use in the events table' do
    expect(subject.class.counter_attribute_foreign_key).to eq(counter_attribute_foreign_key)
  end

  it 'captures the counter attributes defined for the model' do
    expect(subject.class.counter_attributes).to contain_exactly(*counter_attributes)
  end

  shared_examples 'logs a new event' do |attribute|
    it 'in the events table' do
      expect(ConsolidateCountersWorker).to receive(:perform_in).once.and_return(nil)
      expect { subject.increment_counter!(attribute, 17) }
        .to change { counter_attribute_events_class.count }.by(1)

      event = counter_attribute_events_class.last
      expect(event.send(counter_attribute_foreign_key)).to eq(subject.id)
      expect(event.build_artifacts_size).to eq(17)
    end
  end

  counter_attributes.each do |attribute|
    describe attribute do
      before do
        Gitlab::Redis::SharedState.with do |redis|
          redis.del("consolidate-counters:scheduling:ProjectStatistics")
        end
      end

      describe "#increment_counter!" do
        it_behaves_like 'logs a new event', attribute

        it 'raises ActiveRecord exception if invalid record' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)

          expect { subject.increment_counter!(attribute, nil) }
            .to raise_error(ActiveRecord::NotNullViolation)
        end

        it 'does nothing if increment is 0' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)

          expect { subject.increment_counter!(attribute, 0) }
            .not_to change { subject.class.counter_attribute_events_class.count }
        end

        it 'raises error if runs inside a transaction' do
          expect do
            subject.transaction do
              subject.increment_counter!(attribute, 10)
            end
          end.to raise_error(CounterAttribute::TransactionForbiddenError)
        end

        it 'raises error if non counter attribute is incremented' do
          expect do
            subject.increment_counter!(:something_else, 10)
          end.to raise_error(CounterAttribute::UnknownAttributeError)
        end

        context 'when feature flag is disabled' do
          before do
            stub_feature_flags(efficient_counter_attribute: false)
          end

          it 'increments the counter inline' do
            expect(subject).to receive(:update!).with(attribute => 10).and_call_original

            subject.increment_counter(attribute, 10)
          end
        end
      end

      describe "#increment_counter" do
        it_behaves_like 'logs a new event', attribute

        it 'logs ActiveRecord errors and returns false' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)
          expect(Gitlab::ErrorTracking).to receive(:track_exception).with(anything, {
            model: subject.class.name,
            id: subject.id,
            counter_attribute: attribute,
            increment: nil
          })

          expect(subject.increment_counter(attribute, nil)).to be_falsey
        end

        it 'raises an error if attribute is not a counter attribute' do
          expect(ConsolidateCountersWorker).not_to receive(:perform_in)

          expect { subject.increment_counter(:unknown_attribute, 10) }.to raise_error(CounterAttribute::UnknownAttributeError)
        end

        it 'schedules the worker once on multiple increments' do
          expect(ConsolidateCountersWorker).to receive(:perform_in).once.and_return(nil)

          subject.increment_counter(attribute, 10)
          subject.increment_counter(attribute, -40)
        end
      end

      describe "accurate_#{attribute}" do
        before do
          subject.update_column(attribute, 100)
        end

        context 'when there are no pending events' do
          it 'reads the value from the model table' do
            expect(subject.send("accurate_#{attribute}")).to eq(100)
          end
        end

        context 'when there are pending events' do
          it 'reads the value from the model table and sums the pending events' do
            subject.increment_counter(attribute, 10)
            subject.increment_counter(attribute, -40)

            expect(subject.send("accurate_#{attribute}")).to eq(70)
          end
        end
      end

      describe "##{attribute}" do
        before do
          subject.update_column(attribute, 100)
        end

        context 'when there are no pending events' do
          it 'reads the value from the model table' do
            expect(subject.send(attribute)).to eq(100)
          end
        end

        context 'when there are pending events' do
          it 'reads the value from the model table without including events' do
            subject.increment_counter(attribute, 10)
            subject.increment_counter(attribute, -40)

            expect(subject.send(attribute)).to eq(100)
          end
        end
      end
    end
  end
end
