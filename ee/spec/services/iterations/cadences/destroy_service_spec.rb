# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Iterations::Cadences::DestroyService do
  subject(:results) { described_class.new(iteration_cadence, user).execute }

  let_it_be(:group, refind: true) { create(:group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:iteration_cadence, refind: true) { create(:iterations_cadence, group: group, start_date: Date.today, duration_in_weeks: 1, iterations_in_advance: 2) }

  RSpec.shared_examples 'cadence destroy fails with message' do |message:|
    it { is_expected.to be_error }

    it 'returns not allowed message' do
      expect(results.message).to eq(message)
    end
  end

  describe '#execute' do
    context 'when iterations feature enabled' do
      before do
        stub_licensed_features(iterations: true)
      end

      context 'when user is authorized' do
        before do
          group.add_developer(user)
        end

        it { is_expected.to be_success }

        it 'destroys the cadence' do
          expect do
            results
          end.to change(Iterations::Cadence, :count).by(-1)
        end

        it 'returns the cadence as part of the response' do
          expect(results.payload[:iteration_cadence]).to eq(iteration_cadence)
        end
      end

      context 'when user is not authorized' do
        it_behaves_like 'cadence destroy fails with message', message: 'Operation not allowed'
      end
    end

    context 'when iterations feature disabled' do
      before do
        stub_licensed_features(iterations: false)
      end

      context 'when user is authorized' do
        before do
          group.add_developer(user)
        end

        it_behaves_like 'cadence destroy fails with message', message: 'Operation not allowed'
      end

      context 'when user is not authorized' do
        it_behaves_like 'cadence destroy fails with message', message: 'Operation not allowed'
      end
    end

    context 'when iteration cadences feature flag disabled' do
      before do
        stub_licensed_features(iterations: true)
        stub_feature_flags(iteration_cadences: false)
      end

      context 'when user is authorized' do
        before do
          group.add_developer(user)
        end

        it_behaves_like 'cadence destroy fails with message', message: 'Operation not allowed'
      end

      context 'when user is not authorized' do
        it_behaves_like 'cadence destroy fails with message', message: 'Operation not allowed'
      end
    end
  end
end
