# frozen_string_literal: true

require 'spec_helper'
require_migration!

RSpec.describe MigrateDesignNotesMentionsToDb, :sidekiq do
  let(:users) { table(:users) }
  let(:projects) { table(:projects) }
  let(:namespaces) { table(:namespaces) }
  let(:designs) { table(:design_management_designs) }
  let(:design_user_mentions) { table(:design_user_mentions) }
  let(:notes) { table(:notes) }

  let(:user) { users.create!(name: 'root', email: 'root@example.com', username: 'root', projects_limit: 0) }
  let(:group) { namespaces.create!(name: 'group1', path: 'group1', owner_id: user.id) }
  let(:project) { projects.create!(name: 'gitlab1', path: 'gitlab1', namespace_id: group.id, visibility_level: 0) }
  let(:design) { designs.create!(filename: 'test.png', project_id: project.id) }

  let!(:resource1) { notes.create!(note: 'note1 for @root to check', noteable_id: design.id, noteable_type: 'DesignManagement::Design') }
  let!(:resource2) { notes.create!(note: 'note2 for @root to check', noteable_id: design.id, noteable_type: 'DesignManagement::Design', system: true) }
  let!(:resource3) { notes.create!(note: 'note3 for @root to check', noteable_id: design.id, noteable_type: 'DesignManagement::Design') }

  # non-migrateable resources
  # this note is already migrated, as it has a record in the design_user_mentions table
  let!(:resource4) { notes.create!(note: 'note3 for @root to check', noteable_id: design.id, noteable_type: 'DesignManagement::Design') }
  let!(:user_mention) { design_user_mentions.create!(design_id: design.id, note_id: resource4.id, mentioned_users_ids: [1]) }
  # this note points to an innexistent noteable record
  let!(:resource5) { notes.create!(note: 'note3 for @root to check', noteable_id: non_existing_record_id, noteable_type: 'DesignManagement::Design') }

  before do
    stub_const("#{described_class.name}::BATCH_SIZE", 1)
  end

  it_behaves_like 'schedules resource mentions migration', DesignManagement::Design, true
end
