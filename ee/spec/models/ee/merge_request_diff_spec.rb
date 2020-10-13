# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MergeRequestDiff do
  using RSpec::Parameterized::TableSyntax
  include EE::GeoHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, :repository, group: group) }
  let_it_be(:other_project) { create(:project, :repository) }

  it { is_expected.to respond_to(:log_geo_deleted_event) }

  before do
    stub_external_diffs_setting(enabled: true)
  end

  describe '.with_files_stored_locally' do
    it 'includes states with local storage' do
      create(:merge_request, source_project: project)

      expect(described_class.with_files_stored_locally).to have_attributes(count: 1)
    end

    it 'excludes states with local storage' do
      stub_external_diffs_object_storage(ExternalDiffUploader, direct_upload: true)

      create(:merge_request, source_project: project)

      expect(described_class.with_files_stored_locally).to have_attributes(count: 0)
    end
  end

  describe '.has_external_diffs' do
    it 'only includes diffs with files' do
      diff_with_files = create(:merge_request).merge_request_diff
      create(:merge_request, :without_diffs)

      expect(described_class.has_external_diffs).to contain_exactly(diff_with_files)
    end

    it 'only includes externally stored diffs' do
      external_diff = create(:merge_request).merge_request_diff

      stub_external_diffs_setting(enabled: false)

      create(:merge_request, :without_diffs)

      expect(described_class.has_external_diffs).to contain_exactly(external_diff)
    end
  end

  describe '.project_id_in' do
    it 'only includes diffs for the provided projects' do
      diff = create(:merge_request, source_project: project).merge_request_diff
      other_diff = create(:merge_request, source_project: other_project).merge_request_diff
      create(:merge_request)

      expect(described_class.project_id_in([project, other_project])).to contain_exactly(diff, other_diff)
    end
  end

  describe '.replicables_for_geo_node' do
    context 'without selective sync or object storage' do
      let(:secondary) { create(:geo_node) }

      before do
        stub_current_geo_node(secondary)
      end

      it 'excludes diffs stored in the database' do
        stub_external_diffs_setting(enabled: false)

        create(:merge_request, source_project: project)

        expect(described_class.replicables_for_geo_node).to be_empty
      end

      it 'excludes empty diffs' do
        create(:merge_request, source_project: create(:project))

        expect(described_class.replicables_for_geo_node).to be_empty
      end
    end

    where(:selective_sync_enabled, :object_storage_sync_enabled, :diff_in_object_storage, :synced_states) do
      true  | true  | true  | 1
      true  | true  | false | 1
      true  | false | true  | 0
      true  | false | false | 1
      false | false | false | 2
      false | false | true  | 0
      false | true  | true  | 2
      false | true  | false | 2
      true  | true  | false | 1
    end

    with_them do
      let(:secondary) do
        node = build(:geo_node, sync_object_storage: object_storage_sync_enabled)

        if selective_sync_enabled
          node.selective_sync_type = 'namespaces'
          node.namespaces = [group]
        end

        node.save!
        node
      end

      before do
        stub_current_geo_node(secondary)

        stub_external_diffs_object_storage(ExternalDiffUploader, direct_upload: true) if diff_in_object_storage

        create(:merge_request, source_project: project)
        create(:merge_request, source_project: other_project)
      end

      it 'returns the proper number of merge request diff states' do
        expect(described_class.replicables_for_geo_node).to have_attributes(count: synced_states)
      end
    end
  end
end
