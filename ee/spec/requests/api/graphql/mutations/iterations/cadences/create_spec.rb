# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creating an Iterations Cadence' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }

  let(:start_date) { Time.now.strftime('%F') }
  let(:attributes) do
    {
      title: 'title',
      start_date: start_date,
      duration_in_weeks: 1,
      iterations_in_advance: 1
    }
  end

  let(:params) do
    {
      group_path: group.full_path
    }
  end

  let(:mutation) do
    graphql_mutation(:create_iterations_cadence, params.merge(attributes))
  end

  def mutation_response
    graphql_mutation_response(:create_iterations_cadence)
  end

  context 'when the user does not have permission' do
    before do
      stub_licensed_features(iterations: true)
    end

    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create iteration' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Iterations::Cadence, :count)
    end
  end

  context 'when the user has permission' do
    before do
      group.add_developer(current_user)
    end

    context 'when iterations are disabled' do
      before do
        stub_licensed_features(iterations: false)
      end

      it_behaves_like 'a mutation that returns top-level errors',
                      errors: ['The resource that you are attempting to access does not '\
                 'exist or you don\'t have permission to perform this action']
    end

    context 'when iterations are enabled' do
      before do
        stub_licensed_features(iterations: true)
      end

      it 'creates the iteration for a group' do
        post_graphql_mutation(mutation, current_user: current_user)

        iterations_cadence_hash = mutation_response['iterationsCadence']
        aggregate_failures do
          expect(iterations_cadence_hash['title']).to eq('title')
          expect(iterations_cadence_hash['startDate']).to eq(start_date)
        end
      end

      context 'when there are ActiveRecord validation errors' do
        let(:attributes) { { title: '', duration_in_weeks: 1 } }

        it_behaves_like 'a mutation that returns errors in the response',
                        errors: ["Start date can't be blank", "Title can't be blank"]

        it 'does not create the iteration' do
          expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Iterations::Cadence, :count)
        end
      end

      context 'when the list of attributes is empty' do
        let(:attributes) { {} }

        it_behaves_like 'a mutation that returns top-level errors', errors: ['The list of iteration attributes is empty']

        it 'does not create the iteration' do
          expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Iterations::Cadence, :count)
        end
      end
    end
  end
end
