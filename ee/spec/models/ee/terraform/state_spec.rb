# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Terraform::State do
  using RSpec::Parameterized::TableSyntax
  include EE::GeoHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }
  subject { create(:terraform_state, :with_file) }

  describe '.with_files_stored_locally' do
    it 'includes states with local storage' do
      create_list(:terraform_state, 5, :with_file)

      expect(described_class.with_files_stored_locally).to have_attributes(count: 5)
    end

    it 'excludes states without local storage' do
      stub_terraform_state_object_storage

      create_list(:terraform_state, 5, :with_file)

      expect(described_class.with_files_stored_locally).to have_attributes(count: 0)
    end
  end

  describe '.replicables_for_geo_node' do
    where(:selective_sync_enabled, :object_storage_sync_enabled, :terraform_object_storage_enabled, :synced_states) do
      true  | true  | true  | 5
      true  | true  | false | 5
      true  | false | true  | 0
      true  | false | false | 5
      false | false | false | 10
      false | false | true  | 0
      false | true  | true  | 10
      false | true  | false | 10
      true  | true  | false | 5
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
        stub_terraform_state_object_storage if terraform_object_storage_enabled

        create_list(:terraform_state, 5, :with_file, project: project)
        create_list(:terraform_state, 5, :with_file, project: create(:project))
      end

      it 'returns the proper number of terraform states' do
        expect(Terraform::State.replicables_for_geo_node.count).to eq(synced_states)
      end
    end

    context 'state versioning' do
      let(:secondary) { create(:geo_node, sync_object_storage: true) }

      before do
        stub_current_geo_node(secondary)
        stub_terraform_state_object_storage

        create_list(:terraform_state, 5, project: project)
      end

      it 'excludes versioned states' do
        expect(Terraform::State.replicables_for_geo_node.count).to be_zero
      end
    end
  end
end
