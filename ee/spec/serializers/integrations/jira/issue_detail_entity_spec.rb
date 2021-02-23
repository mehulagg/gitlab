# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Integrations::Jira::IssueDetailEntity do
  include JiraServiceHelper

  let_it_be(:project) { create(:project) }
  let_it_be(:jira_service) { create(:jira_service, project: project, url: 'http://jira.com', api_url: 'http://api.jira.com') }

  let(:reporter) do
    double(
      'displayName' => 'reporter',
      'avatarUrls' => { '48x48' => 'http://reporter.avatar' },
      'name' => double
    )
  end

  let(:assignee) do
    double(
      'displayName' => 'assignee',
      'avatarUrls' => { '48x48' => 'http://assignee.avatar' },
      'name' => double
    )
  end

  let(:jira_issue) do
    double(
      summary: 'Title',
      renderedFields: { 'description' => '<p>Description</p>' },
      created: '2020-06-25T15:39:30.000+0000',
      updated: '2020-06-26T15:38:32.000+0000',
      duedate: '2020-06-27T15:40:30.000+0000',
      resolutiondate: '2020-06-27T13:23:51.000+0000',
      labels: ['backend'],
      reporter: reporter,
      assignee: assignee,
      project: double(key: 'GL'),
      key: 'GL-5',
      status: double(name: 'To Do')
    )
  end

  subject { described_class.new(jira_issue, project: project).as_json }

  it 'returns the Jira issues attributes' do
    expect(subject).to include(
      project_id: project.id,
      title: 'Title',
      description_html: "<p dir=\"auto\">Description</p>",
      created_at: '2020-06-25T15:39:30.000+0000'.to_datetime.utc,
      updated_at: '2020-06-26T15:38:32.000+0000'.to_datetime.utc,
      due_date: '2020-06-27T15:40:30.000+0000'.to_datetime.utc,
      closed_at: '2020-06-27T13:23:51.000+0000'.to_datetime.utc,
      status: 'To Do',
      state: 'closed',
      labels: [
        {
          title: 'backend',
          name: 'backend',
          color: '#EBECF0',
          text_color: '#283856'
        }
      ],
      author: hash_including(
        name: 'reporter',
        avatar_url: 'http://reporter.avatar'
      ),
      assignees: [
        hash_including(
          name: 'assignee',
          avatar_url: 'http://assignee.avatar'
        )
      ],
      web_url: 'http://jira.com/browse/GL-5',
      references: { relative: 'GL-5' },
      external_tracker: 'jira'
    )
  end

  context 'with Jira Server configuration' do
    before do
      allow(reporter).to receive(:name).and_return('reporter@reporter.com')
      allow(assignee).to receive(:name).and_return('assignee@assignee.com')
    end

    it 'returns the Jira Server profile URL' do
      expect(subject[:author]).to include(web_url: 'http://jira.com/secure/ViewProfile.jspa?name=reporter@reporter.com')
      expect(subject[:assignees].first).to include(web_url: 'http://jira.com/secure/ViewProfile.jspa?name=assignee@assignee.com')
    end

    context 'with only url' do
      before do
        stub_jira_service_test
        jira_service.update!(api_url: nil)
      end

      it 'returns URLs with the web url' do
        expect(subject[:author]).to include(web_url: 'http://jira.com/secure/ViewProfile.jspa?name=reporter@reporter.com')
        expect(subject[:web_url]).to eq('http://jira.com/browse/GL-5')
      end
    end
  end

  context 'with Jira Cloud configuration' do
    before do
      allow(reporter).to receive(:accountId).and_return('12345')
      allow(assignee).to receive(:accountId).and_return('67890')
    end

    it 'returns the Jira Cloud profile URL' do
      expect(subject[:author]).to include(web_url: 'http://jira.com/people/12345')
      expect(subject[:assignees].first).to include(web_url: 'http://jira.com/people/67890')
    end
  end

  context 'without assignee' do
    before do
      allow(jira_issue).to receive(:assignee).and_return(nil)
    end

    it 'returns an empty array' do
      expect(subject).to include(assignees: [])
    end
  end

  context 'without labels' do
    before do
      allow(jira_issue).to receive(:labels).and_return([])
    end

    it 'returns an empty array' do
      expect(subject).to include(labels: [])
    end
  end

  context 'without resolution date' do
    before do
      allow(jira_issue).to receive(:resolutiondate).and_return(nil)
    end

    it "returns 'Open' state" do
      expect(subject).to include(state: 'opened')
    end
  end
end
