# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Experiment do
  subject { build(:experiment) }

  describe 'associations' do
    it { is_expected.to have_many(:experiment_users) }
    it { is_expected.to have_many(:experiment_subjects) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  describe '.add_user' do
    let_it_be(:experiment_name) { :experiment_key }
    let_it_be(:user) { 'a user' }
    let_it_be(:group) { 'a group' }
    let_it_be(:context) { { a: 42 } }

    subject(:add_user) { described_class.add_user(experiment_name, group, user, context) }

    context 'when an experiment with the provided name does not exist' do
      it 'creates a new experiment record' do
        allow_next_instance_of(described_class) do |experiment|
          allow(experiment).to receive(:record_user_and_group).with(user, group, context)
        end
        expect { add_user }.to change(described_class, :count).by(1)
      end

      it 'forwards the user, group_type, and context to the instance' do
        expect_next_instance_of(described_class) do |experiment|
          expect(experiment).to receive(:record_user_and_group).with(user, group, context)
        end
        add_user
      end
    end

    context 'when an experiment with the provided name already exists' do
      let_it_be(:experiment) { create(:experiment, name: experiment_name) }

      it 'does not create a new experiment record' do
        allow_next_found_instance_of(described_class) do |experiment|
          allow(experiment).to receive(:record_user_and_group).with(user, group, context)
        end
        expect { add_user }.not_to change(described_class, :count)
      end

      it 'forwards the user, group_type, and context to the instance' do
        expect_next_found_instance_of(described_class) do |experiment|
          expect(experiment).to receive(:record_user_and_group).with(user, group, context)
        end
        add_user
      end
    end

    it 'works without the optional context argument' do
      allow_next_instance_of(described_class) do |experiment|
        expect(experiment).to receive(:record_user_and_group).with(user, group, {})
      end

      expect { described_class.add_user(experiment_name, group, user) }.not_to raise_error
    end
  end

  describe '.record_conversion_event' do
    let_it_be(:user) { build(:user) }

    let(:experiment_key) { :test_experiment }

    subject(:record_conversion_event) { described_class.record_conversion_event(experiment_key, user) }

    context 'when no matching experiment exists' do
      it 'creates the experiment and uses it' do
        expect_next_instance_of(described_class) do |experiment|
          expect(experiment).to receive(:record_conversion_event_for_user)
        end
        expect { record_conversion_event }.to change { described_class.count }.by(1)
      end

      context 'but we are unable to successfully create one' do
        let(:experiment_key) { nil }

        it 'raises a RecordInvalid error' do
          expect { record_conversion_event }.to raise_error(ActiveRecord::RecordInvalid)
        end
      end
    end

    context 'when a matching experiment already exists' do
      before do
        create(:experiment, name: experiment_key)
      end

      it 'sends record_conversion_event_for_user to the experiment instance' do
        expect_next_found_instance_of(described_class) do |experiment|
          expect(experiment).to receive(:record_conversion_event_for_user).with(user)
        end
        record_conversion_event
      end
    end
  end

  describe '#record_conversion_event_for_user' do
    let_it_be(:user) { create(:user) }
    let_it_be(:experiment) { create(:experiment) }

    subject(:record_conversion_event_for_user) { experiment.record_conversion_event_for_user(user) }

    context 'when no existing experiment_user record exists for the given user' do
      it 'does not update or create an experiment_user record' do
        expect { record_conversion_event_for_user }.not_to change { ExperimentUser.all.to_a }
      end
    end

    context 'when an existing experiment_user exists for the given user' do
      context 'but it has already been converted' do
        let!(:experiment_user) { create(:experiment_user, experiment: experiment, user: user, converted_at: 2.days.ago) }

        it 'does not update the converted_at value' do
          expect { record_conversion_event_for_user }.not_to change { experiment_user.converted_at }
        end
      end

      context 'and it has not yet been converted' do
        let(:experiment_user) { create(:experiment_user, experiment: experiment, user: user) }

        it 'updates the converted_at value' do
          expect { record_conversion_event_for_user }.to change { experiment_user.reload.converted_at }
        end
      end
    end
  end

  describe '#record_user_and_group' do
    let_it_be(:experiment) { create(:experiment) }
    let_it_be(:user) { create(:user) }

    let(:group) { :control }
    let(:context) { { a: 42 } }

    subject(:record_user_and_group) { experiment.record_user_and_group(user, group, context) }

    context 'when an experiment_user does not yet exist for the given user' do
      it 'creates a new experiment_user record' do
        expect { record_user_and_group }.to change(ExperimentUser, :count).by(1)
      end

      it 'assigns the correct group_type to the experiment_user' do
        record_user_and_group
        expect(ExperimentUser.last.group_type).to eq('control')
      end

      it 'adds the correct context to the experiment_user' do
        record_user_and_group
        expect(ExperimentUser.last.context).to eq({ 'a' => 42 })
      end
    end

    context 'when an experiment_user already exists for the given user' do
      before do
        # Create an existing experiment_user for this experiment and the :control group
        experiment.record_user_and_group(user, :control)
      end

      it 'does not create a new experiment_user record' do
        expect { record_user_and_group }.not_to change(ExperimentUser, :count)
      end

      context 'but the group_type and context has changed' do
        let(:group) { :experimental }

        it 'updates the existing experiment_user record with group_type' do
          expect { record_user_and_group }.to change { ExperimentUser.last.group_type }
        end
      end
    end

    context 'when a context already exists' do
      let_it_be(:context) { { a: 42, 'b' => 34, 'c': { c1: 100, c2: 'c2', e: :e }, d: [1, 3] } }
      let_it_be(:initial_expected_context) { { 'a' => 42, 'b' => 34, 'c' => { 'c1' => 100, 'c2' => 'c2', 'e' => 'e' }, 'd' => [1, 3] } }

      before do
        record_user_and_group
        experiment.record_user_and_group(user, :control, {})
      end

      it 'has an initial context with stringified keys' do
        expect(ExperimentUser.last.context).to eq(initial_expected_context)
      end

      context 'when updated' do
        before do
          record_user_and_group
          experiment.record_user_and_group(user, :control, new_context)
        end

        context 'with an empty context' do
          let_it_be(:new_context) { {} }

          it 'keeps the initial context' do
            expect(ExperimentUser.last.context).to eq(initial_expected_context)
          end
        end

        context 'with string keys' do
          let_it_be(:new_context) { { f: :some_symbol } }

          it 'adds new symbols stringified' do
            expected_context = initial_expected_context.merge('f' => 'some_symbol')
            expect(ExperimentUser.last.context).to eq(expected_context)
          end
        end

        context 'with atomic values or array values' do
          let_it_be(:new_context) { { b: 97, d: [99] } }

          it 'overrides the values' do
            expected_context = { 'a' => 42, 'b' => 97, 'c' => { 'c1' => 100, 'c2' => 'c2', 'e' => 'e' }, 'd' => [99] }
            expect(ExperimentUser.last.context).to eq(expected_context)
          end
        end

        context 'with nested hashes' do
          let_it_be(:new_context) { { c: { g: 107 } } }

          it 'inserts nested additional values in the same keys' do
            expected_context = initial_expected_context.deep_merge('c' => { 'g' => 107 })
            expect(ExperimentUser.last.context).to eq(expected_context)
          end
        end
      end
    end
  end
end
