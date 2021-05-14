# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::BackgroundMigration::CleanupOrphanedLfsObjectsProjects, schema: 20210514063252 do
  let(:lfs_objects_projects) { table(:lfs_objects_projects) }
  let(:lfs_objects) { table(:lfs_objects) }
  let(:projects) { table(:projects) }

  let(:project) { projects.create!(id: 1, namespace_id: 1) }
  let(:another_project) { projects.create!(id: 2, namespace_id: 1) }
  let(:lfs_object) { lfs_objects.create!(id: 1, oid: 'abcdef', size: 1) }
  let(:another_lfs_object) { lfs_objects.create!(id: 2, oid: '1abcde', size: 2) }

  before do
    ActiveRecord::Base.connection.disable_referential_integrity do
      lfs_objects_projects.create!(id: 1, project_id: project.id, lfs_object_id: non_existing_record_id)
      lfs_objects_projects.create!(id: 2, project_id: another_project.id, lfs_object_id: non_existing_record_id)
      lfs_objects_projects.create!(id: 3, project_id: project.id, lfs_object_id: lfs_object.id)
      lfs_objects_projects.create!(id: 4, project_id: project.id, lfs_object_id: another_lfs_object.id)
      lfs_objects_projects.create!(id: 5, project_id: another_project.id, lfs_object_id: another_lfs_object.id)
      lfs_objects_projects.create!(id: 6, project_id: another_project.id, lfs_object_id: lfs_object.id)
      lfs_objects_projects.create!(id: 7, project_id: non_existing_record_id, lfs_object_id: lfs_object.id)
      lfs_objects_projects.create!(id: 8, project_id: non_existing_record_id, lfs_object_id: another_lfs_object.id)
      lfs_objects_projects.create!(id: 9, project_id: non_existing_record_id, lfs_object_id: non_existing_record_id)
    end
  end

  subject { described_class.new }

  describe '#perform' do
    it 'lfs_objects_projects without an existing lfs object or project are removed' do
      subject.perform(1, 3)

      expect(lfs_objects_projects.all.pluck(:id)).to match_array([3, 4, 5, 6, 7, 8, 9])

      subject.perform(4, 6)

      expect(lfs_objects_projects.all.pluck(:id)).to match_array([3, 4, 5, 6, 7, 8, 9])

      subject.perform(7, 9)

      expect(lfs_objects_projects.all.pluck(:id)).to match_array([3, 4, 5, 6])

      expect(lfs_objects.ids).to contain_exactly(lfs_object.id, another_lfs_object.id)
      expect(projects.ids).to contain_exactly(project.id, another_project.id)
    end

    it 'cache for affected projects is being reset' do
      expect(ProjectCacheWorker).to receive(:perform_async).with(project.id, [], [:lfs_objects_size])
      expect(ProjectCacheWorker).to receive(:perform_async).with(another_project.id, [], [:lfs_objects_size])

      subject.perform(1, 3)

      expect(ProjectCacheWorker).not_to receive(:perform_async)

      subject.perform(4, 6)

      expect(ProjectCacheWorker).not_to receive(:perform_async)

      subject.perform(7, 9)
    end
  end
end
