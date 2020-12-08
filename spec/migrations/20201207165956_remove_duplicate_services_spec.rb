# frozen_string_literal: true

require 'spec_helper'
require Rails.root.join('db', 'post_migrate', '20201207165956_remove_duplicate_services.rb')

RSpec.describe RemoveDuplicateServices do
  let_it_be(:namespaces) { table(:namespaces) }
  let_it_be(:projects) { table(:projects) }
  let_it_be(:services) { table(:services) }

  describe '#up' do
    before do
      stub_const("#{described_class}::BATCH_SIZE", 2)

      namespaces.create(id: 1, name: 'group', path: 'group')

      projects.create(id: 1, namespace_id: 1)
      projects.create(id: 2, namespace_id: 1)
      projects.create(id: 3, namespace_id: 1)
      projects.create(id: 4, namespace_id: 1)

      services.create(id: 1, project_id: 1)
      services.create(id: 2, project_id: 2)
      services.create(id: 3, project_id: 3)
      services.create(id: 4, project_id: 1)
      services.create(id: 5, project_id: 3)
    end

    it 'schedules background jobs for all projects with services' do
      Sidekiq::Testing.fake! do
        freeze_time do
          migrate!

          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(2.minutes, 1, 2)
          expect(described_class::MIGRATION).to be_scheduled_delayed_migration(4.minutes, 3, 3)
          expect(BackgroundMigrationWorker.jobs.size).to eq(2)
        end
      end
    end
  end
end
