# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Mutations::Labels::Create do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }

  let(:params) do
    {
      'title' => 'foo',
      'description' => 'some description',
      'color' => '#FF0000'
    }
  end

  let(:mutation) { graphql_mutation(:create_label, params.merge(extra_params)) }

  def mutation_response
    graphql_mutation_response(:create_label)
  end

  shared_examples_for 'labels create mutation' do
    subject { post_graphql_mutation(mutation, current_user: current_user) }

    context 'when the user does not have permission' do
      it_behaves_like 'a mutation that returns a top-level access error'

      it 'does not create the label' do
        expect { subject }.not_to change { Label.count }
      end
    end

    context 'when the user has permission' do
      before do
        parent.add_developer(current_user)
      end

      context 'when the parent (project_path or group_path) param is given' do
        context 'when everything is ok' do
          it 'creates the label' do
            expect { subject }.to change { Label.count }.from(0).to(1)

            expect(mutation_response).to include(
              'label' => a_hash_including(params))
          end
        end

        it 'does not create a label with the same title' do
          label_factory = parent.is_a?(Group) ? :group_label : :label
          create(label_factory, title: 'foo', parent.class.name.underscore.to_sym => parent)

          expect { subject }.not_to change { Label.count }

          expect(mutation_response).to have_key('label')
          expect(mutation_response['label']).to be_nil
          expect(mutation_response['errors'].first).to eq('Title has already been taken')
        end
      end

      context 'when neither project_path nor group_path param is given' do
        let(:mutation) { graphql_mutation(:create_label, params) }

        it_behaves_like 'a mutation that returns top-level errors',
          errors: ['Exactly one of group_path or project_path arguments is required']

        it 'does not create the board' do
          expect { subject }.not_to change { Board.count }
        end
      end
    end
  end

  context 'when creating a project label' do
    let_it_be(:parent) { create(:project) }
    let(:extra_params) { { project_path: parent.full_path } }

    it_behaves_like 'labels create mutation'
  end

  context 'when creating a group label' do
    let_it_be(:parent) { create(:group) }
    let(:extra_params) { { group_path: parent.full_path } }

    it_behaves_like 'labels create mutation'
  end
end
