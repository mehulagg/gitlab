# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Projects::IncidentsHelper do
  include Gitlab::Routing.url_helpers

  let_it_be(:project) { create(:project) }
  let(:project_path) { project.full_path }
  let(:new_issue_path) { new_project_issue_path(project) }
  let(:issue_path) { project_issues_path(project) }
  let(:params) do
    {
      search: 'search text',
      author_username: 'root',
      assignee_username: 'max.power'
    }
  end

  describe '#incidents_data' do
    let(:expected_incidents_data) do
      {
        'project-path' => project_path,
        'new-issue-path' => new_issue_path,
        'incident-template-name' => 'incident',
        'incident-type' => 'incident',
        'issue-path' => issue_path,
        'empty-list-svg-path' => match_asset_path('/assets/illustrations/incident-empty-state.svg'),
        'text-query': 'search text',
        'author-usernames-query': 'root',
        'assignee-usernames-query': 'max.power'
      }
    end

    subject { helper.incidents_data(project, params) }

    before do
      allow(project).to receive(:feature_available?).with(:status_page).and_return(status_page_feature_available)
    end

    context 'when status page feature is available' do
      let(:status_page_feature_available) { true }

      it { is_expected.to match(expected_incidents_data.merge('published-available' => 'true')) }
    end

    context 'when status page issue is not available' do
      let(:status_page_feature_available) { false }

      it { is_expected.to match(expected_incidents_data) }
    end
  end
end
