# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::SegmentsFinder do
  let_it_be(:admin_user) { create(:user, :admin) }

  subject(:finder_segments) { described_class.new(admin_user, params: params).execute }

  let(:params) { {} }

  describe '#execute' do
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

    before do
      stub_licensed_features(instance_level_devops_adoption: true)
      stub_licensed_features(group_level_devops_adoption: true)
    end

    context 'for instance level' do
      it 'returns segments ordered by name' do
        expect(finder_segments).to eq([segment_2, segment_1, direct_subgroup_segment, indirect_subgroup_segment])
      end

      context 'with direct_descendants_only' do
        let(:params) { super().merge(direct_descendants_only: true) }

        it 'returns direct descendants only' do
          expect(finder_segments).to eq([segment_2, segment_1])
        end
      end
    end

    context 'for group level' do
      let(:params) { super().merge(parent_namespace: segment_1.namespace) }

      it 'returns segments scoped to given namespace ordered by name' do
        expect(finder_segments).to eq([segment_1, direct_subgroup_segment, indirect_subgroup_segment])
      end

      context 'with direct_descendants_only' do
        let(:params) { super().merge(direct_descendants_only: true) }

        it 'returns direct descendants only' do
          expect(finder_segments).to eq([segment_1, direct_subgroup_segment])
        end
      end
    end
  end
end
