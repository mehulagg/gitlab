# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReleasesHelper do
  let(:project) { build(:project, namespace: create(:group)) }
  let(:release) { create(:release, project: project) }

  # rubocop: disable CodeReuse/ActiveRecord
  before do
    helper.instance_variable_set(:@project, project)
    helper.instance_variable_set(:@release, release)
  end
  # rubocop: enable CodeReuse/ActiveRecord

  describe '#group_milestone_project_releases_available?' do
    subject { helper.data_for_edit_release_page[:group_milestones_available] }

    context 'when group milestones association with project releases is enabled' do
      before do
        stub_licensed_features(group_milestone_project_releases: true)
      end

      it { is_expected.to eq("true") }
    end

    context 'when group milestones association with project releases is disabled' do
      before do
        stub_licensed_features(group_milestone_project_releases: false)
      end

      it { is_expected.to eq("false") }
    end
  end
end
