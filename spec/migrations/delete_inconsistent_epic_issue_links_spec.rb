# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20210223175130_delete_inconsistent_epic_issue_links')

RSpec.describe DeleteInconsistentEpicIssueLinks, :migration, :sidekiq do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:issues) { table(:issues) }
  let(:epics) { table(:epics) }
  let(:epic_issues) { table(:epic_issues) }

  let(:user) { users.create!(name: 'root', email: 'root@example.com', username: 'root', projects_limit: 0) }
  let(:group1) { namespaces.create!(name: 'group1', path: 'group1', type: 'Group') }
  let(:group2) { namespaces.create!(name: 'group2', path: 'group2', type: 'Group') }
  let(:project_a) { projects.create!(name: 'project-a', path: 'project-a', namespace_id: group1.id, visibility_level: 0) }
  let(:project_b) { projects.create!(name: 'project-b', path: 'project-b', namespace_id: group1.id, visibility_level: 0) }

  let(:epic) { epics.create!(iid: 1, group_id: group1.id, author_id: user.id, title: 'any', title_html: 'any') }

  let(:issue1) { issues.create!(issue_type: 0, project_id: project_a.id) }
  let(:issue2) { issues.create!(issue_type: 0, project_id: project_a.id) }
  let(:issue3) { issues.create!(issue_type: 0, project_id: project_a.id) }
  let(:issue4) { issues.create!(issue_type: 0, project_id: project_b.id) }

  let!(:epic_issue1) { epic_issues.create!(issue_id: issue1.id, epic_id: epic.id) }
  let!(:epic_issue2) { epic_issues.create!(issue_id: issue2.id, epic_id: epic.id) }
  let!(:epic_issue3) { epic_issues.create!(issue_id: issue3.id, epic_id: epic.id) }
  let!(:epic_issue4) { epic_issues.create!(issue_id: issue4.id, epic_id: epic.id) }

  describe '#up' do
    before do
      project_a.update!(namespace_id: group2.id) # Simulate transferring project-a to group2
    end

    it 'cleanups invalid epic issue links' do
      expect { migrate! }.to change { epic_issues.count }.by(-3)
    end
  end
end
