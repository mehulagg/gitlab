# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Analytics::DevopsAdoption::SegmentsFinder do
  let_it_be(:admin_user) { create(:user, :admin) }

  subject(:finder_segments) { described_class.new(admin_user, params: params).execute }

  let(:params) { {} }

  describe '#execute' do
    let_it_be(:root_group_1) { create(:group, name: 'bbb') }

    let_it_be(:segment_1) { create(:devops_adoption_segment, namespace: root_group_1, display_namespace: nil) }
    let_it_be(:segment_2) { create(:devops_adoption_segment, namespace: root_group_1, display_namespace: root_group_1) }
    let_it_be(:segment_3) { create(:devops_adoption_segment) }

    before do
      stub_licensed_features(instance_level_devops_adoption: true)
      stub_licensed_features(group_level_devops_adoption: true)
    end

    context 'with display_namespace provided' do
      let(:params) { super().merge(display_namespace: root_group_1) }

      it 'returns segments with given display namespace' do
        expect(finder_segments).to eq([segment_2])
      end
    end

    context 'without display_namespace provided' do
      it 'returns all namespace without display_namespace' do
        expect(finder_segments).to eq([segment_1])
      end
    end
  end
end
