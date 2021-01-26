# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Terraform::StateVersion do
  using RSpec::Parameterized::TableSyntax
  include EE::GeoHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, group: group) }

  describe '.replicables_for_current_secondary' do
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

        create_list(:terraform_state_version, 5, terraform_state: create(:terraform_state, project: project))
        create_list(:terraform_state_version, 5, terraform_state: create(:terraform_state, project: create(:project)))
      end

      it 'returns the proper number of terraform states' do
        expect(described_class.replicables_for_current_secondary(1..described_class.last.id).count).to eq(synced_states)
      end
    end
  end
end
