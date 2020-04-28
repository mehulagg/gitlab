# frozen_string_literal: true

require 'spec_helper'

describe 'Creating an Iteration' do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:group) { create(:group) }

  let(:start_date) { Time.now.strftime('%F') }
  let(:end_date) { 1.day.from_now.strftime('%F') }
  let(:attributes) do
    {
        title: 'title',
        description: 'some description',
        start_date: start_date,
        due_date: end_date
    }
  end

  let(:mutation) do
    params = { group_path: group.full_path }.merge(attributes)

    graphql_mutation(:create_iteration, params)
  end

  def mutation_response
    graphql_mutation_response(:create_iteration)
  end

  context 'when the user does not have permission' do
    before do
      stub_licensed_features(iterations: true)
    end

    it_behaves_like 'a mutation that returns top-level errors',
                    errors: ['The resource that you are attempting to access does not exist '\
               'or you don\'t have permission to perform this action']

    it 'does not create iteration' do
      expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Sprint, :count)
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

      it 'creates the iteration' do
        post_graphql_mutation(mutation, current_user: current_user)

        iteration_hash = mutation_response['iteration']
        expect(iteration_hash['title']).to eq('title')
        expect(iteration_hash['description']).to eq('some description')
        expect(iteration_hash['startDate']).to eq(start_date)
        expect(iteration_hash['dueDate']).to eq(end_date)
      end

      context 'when there are ActiveRecord validation errors' do
        let(:attributes) { { title: '' } }

        it_behaves_like 'a mutation that returns errors in the response',
                        errors: ["Title can't be blank", "Start date can't be blank", "Due date can't be blank"]

        it 'does not create the iteration' do
          expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Sprint, :count)
        end
      end

      context 'when the list of attributes is empty' do
        let(:attributes) { {} }

        it_behaves_like 'a mutation that returns top-level errors',
                        errors: ['The list of iteration attributes is empty']

        it 'does not create the iteration' do
          expect { post_graphql_mutation(mutation, current_user: current_user) }.not_to change(Sprint, :count)
        end
      end
    end
  end
end
