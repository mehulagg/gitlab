# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Iterations::CadencesResolver do
  include GraphqlHelpers

  describe '#resolve' do
    let_it_be(:current_user) { create(:user) }
    let_it_be(:group) { create(:group, :private) }
    let_it_be(:project) { create(:project, :private, group: group) }
    let_it_be(:active_group_iterations_cadence) { create(:iterations_cadence, group: group, active: true, duration_in_weeks: 1, title: 'one week iterations') }

    RSpec.shared_examples 'fetches iteration cadences' do
      context 'when user does not have permissions to read iterations cadences' do
        it 'raises error' do
          expect do
            resolve_group_iterations_cadences
          end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when user has permissions to read iterations cadences' do
        it 'returns iterations cadences from parent group' do
          parent.add_developer(current_user)

          cadences = resolve_group_iterations_cadences
          expect(cadences).to contain_exactly(active_group_iterations_cadence)
        end
      end

      context 'when iteration cadences feature is disabled' do
        before do
          stub_feature_flags(iterations_cadences: false)
        end

        it 'raises error' do
          expect do
            resolve_group_iterations_cadences
          end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end

    context 'iterations cadences for project' do
      let(:parent) { project }

      it_behaves_like 'fetches iteration cadences'

      context 'when project does not have a parent group' do
        let_it_be(:project) { create(:project, :private) }

        it 'raises error' do
          project.add_developer(current_user)

          expect do
            resolve_group_iterations_cadences({}, project, { current_user: current_user })
          end.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end

    context 'iterations cadences for group' do
      let(:parent) { group }

      it_behaves_like 'fetches iteration cadences'
    end
  end

  def resolve_group_iterations_cadences(args = {}, obj = parent, context = { current_user: current_user })
    resolve(described_class, obj: obj, args: args, ctx: context)
  end
end
