# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Geo::LfsObjectRegistry, :geo do
  include EE::GeoHelpers

  it_behaves_like 'a BulkInsertSafe model', Geo::LfsObjectRegistry do
    let(:valid_items_for_bulk_insertion) { build_list(:geo_lfs_object_registry, 10) }
    let(:invalid_items_for_bulk_insertion) { [] } # class does not have any validations defined
  end

  describe 'relationships' do
    it { is_expected.to belong_to(:lfs_object).class_name('LfsObject') }
  end

  describe '.find_registry_differences' do
    let_it_be(:secondary) { create(:geo_node) }

    let_it_be(:synced_group) { create(:group) }
    let_it_be(:nested_group_1) { create(:group, parent: synced_group) }
    let_it_be(:synced_project) { create(:project, group: synced_group) }
    let_it_be(:synced_project_in_nested_group) { create(:project, group: nested_group_1) }
    let_it_be(:unsynced_project) { create(:project) }
    let_it_be(:project_broken_storage) { create(:project, :broken_storage) }

    before do
      stub_current_geo_node(secondary)
      stub_lfs_object_storage
    end

    let_it_be(:lfs_object_1) { create(:lfs_object) }
    let_it_be(:lfs_object_2) { create(:lfs_object) }
    let_it_be(:lfs_object_3) { create(:lfs_object) }
    let_it_be(:lfs_object_4) { create(:lfs_object) }
    let_it_be(:lfs_object_5) { create(:lfs_object) }

    let!(:lfs_object_remote_1) { create(:lfs_object, :object_storage) }
    let!(:lfs_object_remote_2) { create(:lfs_object, :object_storage) }
    let!(:lfs_object_remote_3) { create(:lfs_object, :object_storage) }

    context 'untracked IDs' do
      before do
        create(:geo_lfs_object_registry, lfs_object_id: lfs_object_1.id)
        create(:geo_lfs_object_registry, :failed, lfs_object_id: lfs_object_3.id)
        create(:geo_lfs_object_registry, lfs_object_id: lfs_object_4.id)

        create(:lfs_objects_project, project: synced_project, lfs_object: lfs_object_1)
        create(:lfs_objects_project, project: synced_project_in_nested_group, lfs_object: lfs_object_2)
        create(:lfs_objects_project, project: synced_project_in_nested_group, lfs_object: lfs_object_3)
        create(:lfs_objects_project, project: unsynced_project, lfs_object: lfs_object_4)
        create(:lfs_objects_project, project: project_broken_storage, lfs_object: lfs_object_5)
      end

      it 'includes LFS object IDs without an entry on the tracking database' do
        untracked_ids, _ = described_class.find_registry_differences(LfsObject.first.id..LfsObject.last.id)

        expect(untracked_ids).to match_array(
          [lfs_object_2.id, lfs_object_5.id, lfs_object_remote_1.id,
           lfs_object_remote_2.id, lfs_object_remote_3.id])
      end

      it 'excludes LFS objects outside the ID range' do
        untracked_ids, _ = described_class.find_registry_differences(lfs_object_3.id..lfs_object_remote_2.id)

        expect(untracked_ids).to match_array(
          [lfs_object_5.id, lfs_object_remote_1.id,
           lfs_object_remote_2.id])
      end

      context 'with selective sync by namespace' do
        let(:secondary) { create(:geo_node, selective_sync_type: 'namespaces', namespaces: [synced_group]) }

        it 'excludes LFS object IDs that are not in selectively synced projects' do
          untracked_ids, _ = described_class.find_registry_differences(LfsObject.first.id..LfsObject.last.id)

          expect(untracked_ids).to match_array([lfs_object_2.id])
        end
      end

      context 'with selective sync by shard' do
        let(:secondary) { create(:geo_node, selective_sync_type: 'shards', selective_sync_shards: ['broken']) }

        it 'excludes LFS object IDs that are not in selectively synced projects' do
          untracked_ids, _ = described_class.find_registry_differences(LfsObject.first.id..LfsObject.last.id)

          expect(untracked_ids).to match_array([lfs_object_5.id])
        end
      end

      context 'with object storage sync disabled' do
        let(:secondary) { create(:geo_node, :local_storage_only) }

        it 'excludes LFS objects in object storage' do
          untracked_ids, _ = described_class.find_registry_differences(LfsObject.first.id..LfsObject.last.id)

          expect(untracked_ids).to match_array([lfs_object_2.id, lfs_object_5.id])
        end
      end
    end

    context 'unused tracked IDs' do
      context 'with an orphaned registry' do
        let!(:orphaned) { create(:geo_lfs_object_registry, lfs_object_id: non_existing_record_id) }

        it 'includes tracked IDs that do not exist in the model table' do
          range = non_existing_record_id..non_existing_record_id

          _, unused_tracked_ids = described_class.find_registry_differences(range)

          expect(unused_tracked_ids).to match_array([non_existing_record_id])
        end

        it 'excludes IDs outside the ID range' do
          range = 1..1000

          _, unused_tracked_ids = described_class.find_registry_differences(range)

          expect(unused_tracked_ids).to be_empty
        end
      end

      context 'with selective sync by namespace' do
        let(:secondary) { create(:geo_node, selective_sync_type: 'namespaces', namespaces: [synced_group]) }

        context 'with a tracked LFS object' do
          let!(:registry_entry) { create(:geo_lfs_object_registry, lfs_object_id: lfs_object_1.id) }
          let(:range) { lfs_object_1.id..lfs_object_1.id }

          context 'excluded from selective sync' do
            it 'includes tracked LFS object IDs that exist but are not in a selectively synced project' do
              _, unused_tracked_ids = described_class.find_registry_differences(range)

              expect(unused_tracked_ids).to match_array([lfs_object_1.id])
            end
          end

          context 'included in selective sync' do
            let!(:join_record) { create(:lfs_objects_project, project: synced_project, lfs_object: lfs_object_1) }

            it 'excludes tracked LFS object IDs that are in selectively synced projects' do
              _, unused_tracked_ids = described_class.find_registry_differences(range)

              expect(unused_tracked_ids).to be_empty
            end
          end
        end
      end

      context 'with selective sync by shard' do
        let(:secondary) { create(:geo_node, selective_sync_type: 'shards', selective_sync_shards: ['broken']) }

        context 'with a tracked LFS object' do
          let!(:registry_entry) { create(:geo_lfs_object_registry, lfs_object_id: lfs_object_1.id) }
          let(:range) { lfs_object_1.id..lfs_object_1.id }

          context 'excluded from selective sync' do
            it 'includes tracked LFS object IDs that exist but are not in a selectively synced project' do
              _, unused_tracked_ids = described_class.find_registry_differences(range)

              expect(unused_tracked_ids).to match_array([lfs_object_1.id])
            end
          end

          context 'included in selective sync' do
            let!(:join_record) { create(:lfs_objects_project, project: project_broken_storage, lfs_object: lfs_object_1) }

            it 'excludes tracked LFS object IDs that are in selectively synced projects' do
              _, unused_tracked_ids = described_class.find_registry_differences(range)

              expect(unused_tracked_ids).to be_empty
            end
          end
        end
      end

      context 'with object storage sync disabled' do
        let(:secondary) { create(:geo_node, :local_storage_only) }

        context 'with a tracked LFS object' do
          context 'in object storage' do
            it 'includes tracked LFS object IDs that are in object storage' do
              create(:geo_lfs_object_registry, lfs_object_id: lfs_object_remote_1.id)
              range = lfs_object_remote_1.id..lfs_object_remote_1.id

              _, unused_tracked_ids = described_class.find_registry_differences(range)

              expect(unused_tracked_ids).to match_array([lfs_object_remote_1.id])
            end
          end

          context 'not in object storage' do
            it 'excludes tracked LFS object IDs that are not in object storage' do
              create(:geo_lfs_object_registry, lfs_object_id: lfs_object_1.id)
              range = lfs_object_1.id..lfs_object_1.id

              _, unused_tracked_ids = described_class.find_registry_differences(range)

              expect(unused_tracked_ids).to be_empty
            end
          end
        end
      end
    end
  end
end
