# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Releases::CreateService do
  let(:group) { create :group }
  let(:project) { create(:project, :repository, group: group) }
  let(:user) { create(:user, maintainer_projects: [project]) }
  let(:tag_name) { 'v1.1.0' }
  let(:name) { 'Bionic Beaver' }
  let(:description) { 'Awesome release!' }
  let(:params) { { tag: tag_name, name: name, description: description } }
  let(:release) { Release.last }
  let(:service) { described_class.new(project, user, params_with_milestones) }

  describe 'group milestones' do
    context 'when a group milestone is passed' do
      let(:group_milestone) { create(:milestone, group: group, title: 'g1') }
      let(:params_with_milestones) { params.merge({ milestones: [group_milestone.title] }) }

      context 'when licenced' do
        before do
          stub_licensed_features(group_milestone_project_releases: true)
        end

        it 'adds the group milestone', :aggregate_failures do
          result = service.execute

          expect(result[:status]).to eq(:success)
          expect(release.milestones).to match_array([group_milestone])
        end
      end

      context 'when unlicensed' do
        it 'returns an error', :aggregate_failures do
          result = service.execute

          expect(result[:status]).to eq(:error)
          expect(result[:message]).to match(/None of the group milestones have the same project as the release/)
        end
      end
    end

    context 'when a supergroup milestone is passed' do
      let(:group) { create(:group, parent: supergroup) }
      let(:supergroup) { create(:group) }
      let(:supergroup_milestone) { create(:milestone, group: supergroup, title: 'sg1') }
      let(:params_with_milestones) { params.merge({ milestones: [supergroup_milestone.title] }) }

      it 'raises an error', :aggregate_failures do
        result = service.execute

        expect(result[:status]).to eq(:error)
        expect(result[:message]).to eq("Milestone(s) not found: sg1")
        expect(release).to be_nil
      end
    end
  end
end
