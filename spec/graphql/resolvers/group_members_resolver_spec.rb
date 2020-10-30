# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::GroupMembersResolver do
  include GraphqlHelpers

  specify do
    expect(described_class.field_options).to include(
      type: eq(Types::GroupMemberType.connection_type),
      null: be_truthy
    )
  end

  it_behaves_like 'querying members with a group' do
    let_it_be(:resource_member) { create(:group_member, user: user_1, group: group_1) }
    let_it_be(:resource) { group_1 }
  end
end
