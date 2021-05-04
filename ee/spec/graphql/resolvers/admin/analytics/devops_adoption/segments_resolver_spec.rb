# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::Analytics::DevopsAdoption::SegmentsResolver do
  include GraphqlHelpers

  let_it_be(:admin_user) { create(:user, :admin) }

  def resolve_segments(args = {}, context = {})
    resolve(described_class, args: args, ctx: context)
  end

  before do
    stub_licensed_features(instance_level_devops_adoption: true, group_level_devops_adoption: true)
  end

  describe '#resolve' do
    let_it_be(:user) { create(:user) }
    let_it_be(:root_group_1) { create(:group, name: 'bbb') }
    let_it_be(:root_group_2) { create(:group, name: 'aaa') }

    let_it_be(:segment_1) { create(:devops_adoption_segment, namespace: root_group_1) }
    let_it_be(:segment_2) { create(:devops_adoption_segment, namespace: root_group_2) }
    let_it_be(:direct_subgroup) { create(:group, name: 'ccc', parent: root_group_1) }
    let_it_be(:direct_subgroup_segment) do
      create(:devops_adoption_segment, namespace: direct_subgroup)
    end

    let_it_be(:indirect_subgroup) { create(:group, name: 'ddd', parent: direct_subgroup) }
    let_it_be(:indirect_subgroup_segment) do
      create(:devops_adoption_segment, namespace: indirect_subgroup)
    end

    subject(:resolved_segments) { resolve_segments(params, { current_user: current_user }) }

    let(:params) { {} }

    context 'for instance level', :enable_admin_mode do
      let(:current_user) { admin_user }

      context 'as an admin user' do
        it 'returns segments for all groups, ordered by name' do
          expect(resolved_segments).to eq([segment_2, segment_1, direct_subgroup_segment, indirect_subgroup_segment])
        end

        context 'with direct_descendants_only' do
          let(:params) { super().merge(direct_descendants_only: true) }

          it 'returns segments for root groups, ordered by name' do
            expect(resolved_segments).to eq([segment_2, segment_1])
          end
        end
      end

      context 'as a non-admin user' do
        let(:current_user) { user }

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the feature is not available' do
        before do
          stub_licensed_features(instance_level_devops_adoption: false)
        end

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end

    context 'for group level' do
      let(:params) { { parent_namespace_id: root_group_1.to_gid.to_s } }
      let(:current_user) { user }

      context 'for reporter+' do
        before do
          root_group_1.add_reporter(user)
        end

        it 'returns segments for given parent group and its descendants' do
          expect(resolved_segments).to eq([segment_1, direct_subgroup_segment, indirect_subgroup_segment])
        end

        context 'with direct_descendants_only' do
          let(:params) { super().merge(direct_descendants_only: true) }

          it 'returns segments for given parent group and its direct descendants' do
            expect(resolved_segments).to eq([segment_1, direct_subgroup_segment])
          end
        end
      end

      context 'for guests' do
        before do
          root_group_1.add_guest(user)
        end

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'when the feature is not available' do
        before do
          stub_licensed_features(instance_level_devops_adoption: false)
        end

        it 'raises ResourceNotAvailable error' do
          expect { resolved_segments }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end
  end
end
