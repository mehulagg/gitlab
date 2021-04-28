# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Groups::AutocompleteSourcesController do
  let_it_be(:user) { create(:user) }
  let_it_be_with_reload(:group) { create(:group, :private) }
  let_it_be(:epic) { create(:epic, group: group) }

  before_all do
    group.add_developer(user)
  end

  before do
    stub_licensed_features(epics: true)
    sign_in(user)
  end

  describe '#epics' do
    it 'returns 200 status' do
      get :epics, params: { group_id: group }

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns the correct response' do
      get :epics, params: { group_id: group }

      expect(json_response).to be_an(Array)
      expect(json_response.first).to include(
        'iid' => epic.iid, 'title' => epic.title, 'reference' => epic.to_reference(epic.group)
      )
    end
  end

  describe '#vulnerabilities' do
    let_it_be_with_reload(:project) { create(:project, :private, group: group) }
    let_it_be(:vulnerability) { create(:vulnerability, project: project) }

    before do
      project.add_developer(user)
      stub_licensed_features(security_dashboard: true)
    end

    it 'returns 200 status' do
      get :vulnerabilities, params: { group_id: group }

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns the correct response', :aggregate_failures do
      get :vulnerabilities, params: { group_id: group }

      expect(json_response).to be_an(Array)
      expect(json_response.first).to include(
        'id' => vulnerability.id, 'title' => vulnerability.title
      )
    end
  end

  describe '#issues' do
    using RSpec::Parameterized::TableSyntax

    let_it_be(:project) { create(:project, group: group) }
    let_it_be(:issue) { create(:issue, project: project) }
    let_it_be(:incident) { create(:incident, project: project) }
    let_it_be(:test_case) { create(:quality_test_case, project: project) }

    let(:none) { [] }
    let(:all) { [issue, incident, test_case] }

    where(:issue_types, :expected) do
      nil         | :all
      ''          | :all
      'invalid'   | :none
      'issue'     | :issue
      'incident'  | :incident
      'test_case' | :test_case
    end

    with_them do
      it 'returns the correct response', :aggregate_failures do
        issues = Array(expected).flat_map { |sym| public_send(sym) }
        params = { group_id: group, issue_types: issue_types }.compact

        get :issues, params: params

        expect(response).to have_gitlab_http_status(:ok)
        expect(json_response).to be_an(Array)
        expect(json_response.size).to eq(issues.size)
        expect(json_response.map { |issue| issue['iid'] })
          .to match_array(issues.map(&:iid))
      end
    end
  end

  describe '#milestones' do
    it 'returns correct response' do
      parent_group = create(:group, :private)
      group.update!(parent: parent_group)
      sub_group = create(:group, :private, parent: sub_group)
      create(:milestone, group: parent_group)
      create(:milestone, group: sub_group)
      group_milestone = create(:milestone, group: group)

      get :milestones, params: { group_id: group }

      expect(response).to have_gitlab_http_status(:ok)
      expect(json_response.count).to eq(1)
      expect(json_response.first).to include(
        'iid' => group_milestone.iid, 'title' => group_milestone.title
      )
    end
  end

  describe '#commands' do
    it 'returns 200 status' do
      get :commands, params: { group_id: group, type: 'Epic', type_id: epic.iid }

      expect(response).to have_gitlab_http_status(:ok)
    end

    it 'returns the correct response' do
      get :commands, params: { group_id: group, type: 'Epic', type_id: epic.iid }

      expect(json_response).to be_an(Array)
      expect(json_response).to include(
        {
          'name' => 'close', 'aliases' => [], 'description' => 'Close this epic',
          'params' => [], 'warning' => '', 'icon' => ''
        }
      )
    end

    it 'handles new epics' do
      get :commands, params: { group_id: group, type: 'Epic', type_id: nil }

      expect(json_response).to be_an(Array)
      expect(json_response).to include(
        {
          'name' => 'cc', 'aliases' => [], 'description' => 'CC',
          'params' => ['@user'], 'warning' => '', 'icon' => ''
        }
      )
    end
  end
end
