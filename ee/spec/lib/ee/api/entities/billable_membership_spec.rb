# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::EE::API::Entities::BillableMembership do
  describe '#as_json' do
    it 'returns source_members_url for a group' do
      membership = create(:group_member)
      group_members_url = Gitlab::Routing.url_helpers.group_group_members_url(membership.source)

      expect(described_class.new(membership).as_json[:source_members_url]).to eq(group_members_url)
    end

    it 'returns source_members_url for a project' do
      membership = create(:project_member)
      project_members_url = Gitlab::Routing.url_helpers.project_project_members_url(membership.source)

      expect(described_class.new(membership).as_json[:source_members_url]).to eq(project_members_url)
    end
  end
end
