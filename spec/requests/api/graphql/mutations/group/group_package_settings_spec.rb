# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'getting group package settings in a group' do
  include GraphqlHelpers

  let_it_be(:group) { create(:group) }
  let_it_be(:current_user) { group.owner }
  let_it_be(:group_package_setting) { group.group_package_setting }

  let(:fields) do
    <<~QUERY
      #{all_graphql_fields_for('group_package_setting'.classify)}
    QUERY
  end

  let(:query) do
    graphql_query_for(
      'group',
      { 'fullPath' => group.full_path },
      query_graphql_field('groupPackageSetting', {}, fields)
    )
  end

  before do
    post_graphql(query, current_user: current_user)
  end

  it_behaves_like 'a working graphql query'
end
