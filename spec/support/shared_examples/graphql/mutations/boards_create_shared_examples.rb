# frozen_string_literal: true

RSpec.shared_examples 'boards create mutation' do
  include GraphqlHelpers

  let_it_be(:current_user, reload: true) { create(:user) }
  let(:name) { 'board name' }
  let(:mutation) { graphql_mutation(:create_board, params) }

  subject { post_graphql_mutation(mutation, current_user: current_user) }

  def mutation_response
    graphql_mutation_response(:create_board)
  end

  context 'when the user does not have permission' do
    it_behaves_like 'a mutation that returns a top-level access error'

    it 'does not create the board' do
      expect { subject }.not_to change { Board.count }
    end
  end

  context 'when the user has permission' do
    before do
      parent.add_maintainer(current_user)
    end

    context 'when the parent (project_path or group_path) param is given' do
      context 'when everything is ok' do
        it 'creates the board' do
          expect { subject }.to change { Board.count }.from(0).to(1)
        end

        it 'returns the created board' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(mutation_response).to have_key('board')
          expect(mutation_response['board']['name']).to eq(name)
        end
      end

      context 'when the Boards::CreateService returns an error response' do
        before do
          allow_next_instance_of(Boards::CreateService) do |service|
            allow(service).to receive(:execute).and_return(ServiceResponse.error(message: 'There was an error.'))
          end
        end

        it 'does not create a board' do
          expect { subject }.not_to change { Board.count }
        end

        it 'returns an error' do
          post_graphql_mutation(mutation, current_user: current_user)

          expect(mutation_response).to have_key('board')
          expect(mutation_response['board']).to be_nil
          expect(mutation_response['errors'].first).to eq('There was an error.')
        end
      end
    end

    context 'when neither project_path nor group_path param is given' do
      let(:params) { { name: name } }

      it_behaves_like 'a mutation that returns top-level errors',
        errors: ['group_path or project_path arguments are required']

      it 'does not create the board' do
        expect { subject }.not_to change { Board.count }
      end
    end
  end
end
