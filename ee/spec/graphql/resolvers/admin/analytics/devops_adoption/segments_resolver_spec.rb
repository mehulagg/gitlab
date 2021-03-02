# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::Admin::Analytics::DevopsAdoption::SegmentsResolver do
  include GraphqlHelpers

  let_it_be(:admin_user) { create(:user, :admin) }
  let(:current_user) { admin_user }

  def resolve_segments(args = {}, context = {})
    resolve(described_class, args: args, ctx: context)
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

    subject { resolve_segments({}, { current_user: current_user }) }

    before do
      stub_licensed_features(instance_level_devops_adoption: true)
      stub_licensed_features(group_level_devops_adoption: true)
    end

    shared_examples 'allowed for admins with proper feature' do |feature|
      context 'when the feature is not available' do
        let(:current_user) { admin_user }

        before do
          stub_licensed_features(feature => false)
        end

        it 'raises ResourceNotAvailable error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end

      context 'as a non-admin user' do
        let(:current_user) { user }

        it 'raises ResourceNotAvailable error' do
          expect { subject }.to raise_error(Gitlab::Graphql::Errors::ResourceNotAvailable)
        end
      end
    end

    context 'for instance level' do
      context 'as an admin user' do
        let(:current_user) { admin_user }

        it 'returns segments for root groups, ordered by name' do
          expect(subject).to eq([segment_2, segment_1])
        end
      end

      it_behaves_like 'allowed for admins with proper feature', :instance_level_devops_adoption
    end

    context 'for group level' do
      subject { resolve_segments({parent_namespace_id: root_group_1.to_gid.to_s }, { current_user: current_user }) }

      context 'as an admin user' do
        let(:current_user) { admin_user }

        it 'returns segments for given paren group and its direct descendants' do
          expect(subject).to eq([direct_subgroup_segment, segment_1])
        end
      end

      it_behaves_like 'allowed for admins with proper feature', :group_level_devops_adoption
    end
  end
end
