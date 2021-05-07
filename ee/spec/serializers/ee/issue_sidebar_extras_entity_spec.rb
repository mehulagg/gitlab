# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IssueSidebarExtrasEntity do
  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  let_it_be(:user) { create(:user) }
  let_it_be(:issue, reload: true) { create(:issue, :confidential, project: project) }

  let(:request) { double('request', current_user: user) }

  subject { described_class.new(issue, request: request).as_json }

  context 'exposing epic' do
    before do
      stub_licensed_features(epics: true)
    end

    context 'when epic is confidential' do
      let_it_be(:confidential_epic) { create(:epic, :confidential, group: group) }
      let_it_be(:epic_issue) { create(:epic_issue, issue: issue, epic: confidential_epic) }

      it 'returns nil for a user who is a project member' do
        project.add_developer(user)

        expect(subject[:epic]).to be_nil
      end

      it 'exposes the epic for a user who is a group member' do
        group.add_developer(user)

        expect(subject[:epic].keys).to match_array([:id, :iid, :title, :url, :group_id, :epic_issue_id])
      end
    end

    context 'when epic is not confidential' do
      let_it_be(:epic) { create(:epic, group: group) }
      let_it_be(:epic_issue) { create(:epic_issue, issue: issue, epic: epic) }

      it 'exposes the epic for a project member' do
        project.add_developer(user)

        expect(subject[:epic].keys).to match_array([:id, :iid, :title, :url, :group_id, :epic_issue_id])
      end

      it 'exposes the epic for a user who is a group member' do
        group.add_developer(user)

        expect(subject[:epic].keys).to match_array([:id, :iid, :title, :url, :group_id, :epic_issue_id])
      end
    end
  end
end
