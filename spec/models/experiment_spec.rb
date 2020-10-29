# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Experiment do
  subject { build(:experiment) }

  describe 'associations' do
    it { is_expected.to have_many(:experiment_users) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
  end

  describe '.add_user' do
    let(:name) { :experiment_key }
    let(:user) { create(:user) }

    let!(:experiment) { create(:experiment, name: name) }

    def add_user(group = :control)
      described_class.add_user(name, group, user)
    end

    describe 'creating a new experiment record' do
      context 'an experiment with the provided name already exists' do
        it 'does not create a new experiment record' do
          expect { add_user }.not_to change(Experiment, :count)
        end
      end

      context 'an experiment with the provided name does not exist yet' do
        let(:experiment) { nil }

        it 'creates a new experiment record' do
          expect { add_user }.to change(Experiment, :count).by(1)
        end
      end
    end

    describe 'creating a new experiment_user record' do
      context 'an experiment_user record for this experiment already exists' do
        it 'does not create a new experiment_user record' do
          add_user
          expect { add_user }.not_to change(ExperimentUser, :count)
        end

        it 'updates the existing experiment_user record' do
          add_user(:control)
          expect { add_user(:experimental) }.to change { ExperimentUser.last.group_type }
        end
      end

      context 'an experiment_user record for this experiment does not exist yet' do
        it 'creates a new experiment_user record' do
          expect { add_user }.to change(ExperimentUser, :count).by(1)
        end

        it 'assigns the correct group_type to the experiment_user' do
          add_user
          expect(ExperimentUser.last.group_type).to eq('control')
        end
      end
    end
  end
end
