# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::API::Entities::Analytics::GroupActivity do
  let(:count) { 10 }

  shared_examples 'exposes count' do |count_type, entity|
    let(:data) { { count_type.to_sym => count } }

    subject(:entity_representation) { entity.new(data).as_json }

    it "exposes #{count_type}" do
      expect(entity_representation).to include({ count_type.to_sym => count })
    end
  end

  context 'issues count' do
    it_behaves_like 'exposes count',
      'issues_count',
      EE::API::Entities::Analytics::GroupActivity::IssuesCount
  end

  context 'merge requests count' do
    it_behaves_like 'exposes count',
      'merge_requests_count',
      EE::API::Entities::Analytics::GroupActivity::MergeRequestsCount
  end

  context 'new members count' do
    it_behaves_like 'exposes count',
      'new_members_count',
      EE::API::Entities::Analytics::GroupActivity::NewMembersCount
  end
end
