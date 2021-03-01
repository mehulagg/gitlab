# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating an Iterations Cadence' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }
  let_it_be(:iterations_cadence) { create(:iterations_cadence, group: group) }

  let(:start_date) { Time.now.strftime('%F') }
  let(:attributes) do
    {
      title: 'title',
      start_date: start_date,
      duration_in_weeks: 1,
      iterations_in_advance: 1,
      automatic: false,
      active: false
    }
  end

  let(:params) do
    { group_path: group.full_path, id: iterations_cadence.to_global_id.to_s }
  end

  let(:mutation) do
    graphql_mutation(:update_iterations_cadence, params.merge(attributes))
  end

  def mutation_response
    graphql_mutation_response(:update_iterations_cadence)
  end

  context 'when the user does not have permission' do
    before do
      stub_licensed_features(iterations: true)
    end

    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create iterations cadence' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Iterations::Cadence, :count)
    end
  end

  context 'when the user has permission' do
    before do
      group.add_developer(current_user)
    end

    context 'when iterations feature is disabled' do
      before do
        stub_licensed_features(iterations: false)
      end

      it_behaves_like 'a mutation that returns top-level errors',
                      errors: ['The resource that you are attempting to access does not '\
                 'exist or you don\'t have permission to perform this action']
    end

    context 'when iterations feature is enabled' do
      before do
        stub_licensed_features(iterations: true)
      end

      it 'updates the iteration', :aggregate_failures do
        post_graphql_mutation(mutation, current_user: current_user)

        iterations_cadence_hash = mutation_response['iterationsCadence']
        expect(iterations_cadence_hash['title']).to eq('title')
        expect(iterations_cadence_hash['startDate'].to_date).to eq(start_date.to_date)
        expect(iterations_cadence_hash['durationInWeeks']).to eq(1)
        expect(iterations_cadence_hash['iterationsInAdvance']).to eq(1)
        expect(iterations_cadence_hash['automatic']).to eq(false)
        expect(iterations_cadence_hash['active']).to eq(false)

        iterations_cadence.reload
        expect(iterations_cadence.title).to eq('title')
        expect(iterations_cadence.start_date).to eq(start_date.to_date)
        expect(iterations_cadence.duration_in_weeks).to eq(1)
        expect(iterations_cadence.iterations_in_advance).to eq(1)
        expect(iterations_cadence.automatic).to eq(false)
        expect(iterations_cadence.active).to eq(false)
      end

      it 'updates an iterations cadence for a group' do
        post_graphql_mutation(mutation, current_user: current_user)

        iterations_cadence_hash = mutation_response['iterationsCadence']
        aggregate_failures do
          expect(iterations_cadence_hash['title']).to eq('title')
          expect(iterations_cadence_hash['startDate']).to eq(start_date)
        end
      end

      context 'when iterations_cadences feature flag is disabled' do
        before do
          stub_feature_flags(iterations_cadences: false)
        end

        it_behaves_like 'a mutation that returns errors in the response', errors: ["Operation not allowed"]
      end

      context 'when there are ActiveRecord validation errors' do
        let(:attributes) { { id: iterations_cadence.to_global_id.to_s, title: '' } }

        it_behaves_like 'a mutation that returns errors in the response',
                        errors: ["Title can't be blank"]

        it 'does not update the iterations cadence' do
          expect do
            post_graphql_mutation(mutation, current_user: current_user)

            iterations_cadence.reload
          end.not_to change(iterations_cadence, :title)
        end
      end

      context 'when required arguments are missing' do
        let(:params) { { group_path: group.full_path } }

        it 'returns error about required argument' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect_graphql_errors_to_include(/was provided invalid value for id \(Expected value to not be null\)/)
        end
      end
    end
  end
end
