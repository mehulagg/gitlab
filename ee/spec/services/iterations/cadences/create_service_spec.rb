# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::Cadences::CreateService do
  let_it_be(:group, refind: true) { create(:group) }
  let_it_be(:user) { create(:user) }

  before do
    group.add_developer(user)
  end

  context 'iterations feature enabled' do
    before do
      stub_licensed_features(iterations: true)
    end

    describe '#execute' do
      let(:params) do
        {
          title: 'My Iterations Cadence',
          start_date: Time.current.to_s,
          duration_in_weeks: 1,
          iterations_in_advance: 1
        }
      end

      let(:response) { described_class.new(group, user, params).execute }
      let(:iterations_cadence) { response.payload[:iterations_cadence] }
      let(:errors) { response.payload[:errors] }

      context 'valid params' do
        it 'creates an iteration' do
          expect(response.success?).to be_truthy
          expect(response.success?).to be_truthy
          expect(iterations_cadence).to be_persisted
          expect(iterations_cadence.title).to eq('My Iterations Cadence')
          expect(iterations_cadence.duration_in_weeks).to eq(1)
          expect(iterations_cadence.iterations_in_advance).to eq(1)
          expect(iterations_cadence.active).to eq(true)
          expect(iterations_cadence.automatic).to eq(true)
        end
      end

      context 'invalid params' do
        let(:params) do
          {
            title: 'My Iterations Cadence'
          }
        end

        it 'does not create an iterations cadence but returns errors' do
          expect(response.error?).to be_truthy
          expect(errors.messages).to match({
            start_date: ["can't be blank"],
            duration_in_weeks: ["can't be blank"],
            iterations_in_advance: ["can't be blank"]
          })
        end
      end

      context 'no permissions' do
        before do
          group.add_reporter(user)
        end

        it 'is not allowed' do
          expect(response.error?).to be_truthy
          expect(response.message).to eq('Operation not allowed')
        end
      end
    end
  end

  context 'iterations feature disabled' do
    before do
      stub_licensed_features(iterations: false)
    end

    describe '#execute' do
      let(:params) { { title: 'a' } }
      let(:response) { described_class.new(group, user, params).execute }

      it 'is not allowed' do
        expect(response.error?).to be_truthy
        expect(response.message).to eq('Operation not allowed')
      end
    end
  end

  context 'iteration cadences feature flag disabled' do
    before do
      stub_licensed_features(iterations: true)
      stub_feature_flags(iterations_cadences: false)
    end

    describe '#execute' do
      let(:params) { { title: 'a' } }
      let(:response) { described_class.new(group, user, params).execute }

      it 'is not allowed' do
        expect(response.error?).to be_truthy
        expect(response.message).to eq('Operation not allowed')
      end
    end
  end
end
