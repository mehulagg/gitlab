# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidebars::Projects::Menus::JiraMenu do
  let_it_be_with_refind(:project) { create(:project, has_external_issue_tracker: true) }

  let(:user) { project.owner }
  let(:context) { Sidebars::Projects::Context.new(current_user: user, container: project, jira_issues_integration: jira_issues_integration) }
  let(:jira_issues_integration) { false }

  subject { described_class.new(context) }

  describe 'render?' do
    context 'when issue tracker is not Jira' do
      it 'returns false' do
        create(:custom_issue_tracker_integration, active: true, project: project, project_url: 'http://test.com')

        expect(subject.render?).to eq false
      end
    end

    context 'when issue tracker is Jira' do
      let!(:jira) { create(:jira_integration, project: project, project_key: 'GL') }

      context 'when issues integration is disabled' do
        it 'returns false' do
          expect(subject.render?).to eq false
        end
      end

      context 'when issues integration is enabled' do
        let(:jira_issues_integration) { true }

        it 'returns true' do
          expect(subject.render?).to eq true
        end

        it 'contains issue list and open jira menu items' do
          expect(subject.renderable_items).not_to be_empty
          expect(subject.renderable_items[0].item_id).to eq :issue_list
          expect(subject.renderable_items[1].item_id).to eq :open_jira
        end
      end
    end
  end
end
