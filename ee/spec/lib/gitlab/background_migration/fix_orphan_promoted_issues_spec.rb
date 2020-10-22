# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::FixOrphanPromotedIssues, schema: 20200207185149 do
  let(:users) { table(:users) }
  let(:namespaces) { table(:namespaces) }
  let(:projects) { table(:projects) }
  let(:issues) { table(:issues) }
  let(:epics) { table(:epics) }
  let(:notes) { table(:notes) }
  let(:migration) { described_class.new }
  let(:group1) { namespaces.create!(name: 'gitlab', path: 'gitlab') }
  let(:project1) { projects.create!(namespace_id: group1.id) }
  let(:group2) { namespaces.create!(name: 'other', path: 'other') }
  let(:project2) { projects.create!(namespace_id: group2.id) }
  let(:user) { users.create(name: 'any', email: 'user@example.com', projects_limit: 9) }
  let!(:epic_from_issue_1) { epics.create(iid: 14532, title: 'from issue 1', group_id: group1.id, author_id: user.id, created_at: Time.now, updated_at: Time.now, title_html: 'any') }
  let!(:epic_from_issue_2) { epics.create(iid: 209, title: 'from issue 2', group_id: group2.id, author_id: user.id, created_at: Time.now, updated_at: Time.now, title_html: 'any') }
  let!(:promoted_orphan) { issues.create!(description: 'promoted 1', state_id: 1, project_id: project1.id) }
  let!(:promoted) { issues.create!(description: 'promoted 3', state_id: 2, project_id: project2.id, promoted_to_epic_id: epic_from_issue_2.id) }
  let!(:promotion_note_1) { notes.create!(project_id: project1.id, noteable_id: promoted_orphan.id, noteable_type: "Issue", note: "promoted to epic &14532", system: true) }
  let!(:promotion_note_2) { notes.create!(project_id: project2.id, noteable_id: promoted.id, noteable_type: "Issue", note: "promoted to epic &209", system: true) }

  context 'when promoted_to_epic_id is missing' do
    it 'populates missing promoted_to_epic_id' do
      expect do
        described_class.new.perform(promotion_note_1.id)
        promoted_orphan.reload
      end.to change { promoted_orphan.promoted_to_epic_id }.from(nil).to(epic_from_issue_1.id)
    end
  end

  context 'when promoted_to_epic_id is present' do
    it 'does not change promoted_to_epic_id' do
      expect do
        described_class.new.perform(promotion_note_2.id)
        promoted.reload
      end.not_to change { promoted.promoted_to_epic_id }
    end
  end
end
