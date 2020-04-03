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

  describe '.counter_events_available?' do
    context 'when there are logged events' do
      let(:attribute) { counter_attributes.first }

      before do
        subject.increment_counter(attribute, 10)
      end

      it 'returns true' do
        expect(subject.class.counter_events_available?).to be_truthy
      end
    end

    context 'when there are no logged events' do
      it 'returns false' do
        expect(subject.class.counter_events_available?).to be_falsey
      end
    end
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

  describe '.slow_consolidate_counter_attributes!' do
    let(:attribute) { counter_attributes.first }

    context 'when it is executed inside an existing database transaction' do
      it 'raises an error' do
        subject.class.transaction do
          expect { subject.class.slow_consolidate_counter_attributes! }
            .to raise_error(CounterAttribute::TransactionForbiddenError)
        end
      end
    end

    context 'when there are pending events for the same object' do
      before do
        subject.increment_counter(attribute, 10)
        subject.increment_counter(attribute, -3)
      end

      it 'updates the counter and removes the events' do
        subject.class.slow_consolidate_counter_attributes!

        expect(subject.reload.public_send(attribute)).to eq 7
        expect(subject.counter_events).to be_empty
      end

      it 'performs 1 query to fetch all IDs and 1 query per record to update' do
        expect { subject.class.slow_consolidate_counter_attributes! }.not_to exceed_query_limit(2)
      end
    end

    context 'when there pending events for different records' do
      let(:subject_2) { create(subject_factory) }
      let(:subject_3) { create(subject_factory) }

      before do
        subject.increment_counter(attribute, 10)
        subject.increment_counter(attribute, -3)

        subject_2.increment_counter(attribute, 30)
        subject_2.increment_counter(attribute, 13)
        subject_2.increment_counter(attribute, -1)

        subject_3.increment_counter(attribute, 20)
      end

      shared_examples 'updates the counters and removes the events' do
        it 'updates the counters' do
          subject.class.slow_consolidate_counter_attributes!

          expect(subject.reload.public_send(attribute)).to eq 7
          expect(subject_2.reload.public_send(attribute)).to eq 42
          expect(subject_3.reload.public_send(attribute)).to eq 20
        end

        it 'removes the events' do
          subject.class.slow_consolidate_counter_attributes!

          expect(subject.reload.counter_events).to be_empty
        end

        it 'returns the count of consolidated subjects' do
          expect(subject.class.slow_consolidate_counter_attributes!).to eq(3)
        end
      end

      it_behaves_like 'updates the counters and removes the events'

      it 'performs 1 query to fetch all IDs and 1 query per record to update' do
        expect { subject.class.slow_consolidate_counter_attributes! }.not_to exceed_query_limit(4)
      end

      context 'when there are more logged events than the consolidation batch size' do
        before do
          stub_const('CounterAttribute::CONSOLIDATION_BATCH_SIZE', 2)
        end

        it_behaves_like 'updates the counters and removes the events'
      end
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

        it 'raises exception if runs inside a transaction' do
          expect(Gitlab::ErrorTracking)
            .to receive(:track_exception)
            .with(instance_of(CounterAttribute::TransactionForbiddenError), attribute: attribute)

          expect do
            subject.class.transaction do
              subject.increment_counter!(attribute, 10)
            end
          end.to raise_error(Sidekiq::Worker::EnqueueFromTransactionError)
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
