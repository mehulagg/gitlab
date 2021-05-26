# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Runner (JavaScript fixtures)', type: :controller do
  include AdminModeHelper
  include ApiHelpers
  include JavaScriptFixturesHelpers

  let(:admin) { create(:admin) }

  let_it_be(:project) { create(:project, :repository, :public) }

  let!(:instance_runner) { create(:ci_runner, :instance, version: 'abc', revision: '123', description: 'Instance runner', ip_address: '127.0.0.1') }
  let!(:project_runner) { create(:ci_runner, :project, active: false, version: 'def', revision: '456', description: 'Project runner', projects: [project], ip_address: '127.0.0.1') }

  before do
    sign_in(admin)
    enable_admin_mode!(admin)
  end

  describe GraphQL::Query, type: :request do
    include GraphqlHelpers

    base_input_path = 'runner/graphql/'
    base_output_path = 'graphql/runner/'

    get_runners_query_name = 'get_runners.query.graphql'
    fragment_paths = ['graphql_shared/fragments/pageInfo.fragment.graphql']

    before(:all) do
      clean_frontend_fixtures(base_output_path)
    end

    it "#{base_output_path}#{get_runners_query_name}.json" do
      query = get_graphql_query_as_string("#{base_input_path}#{get_runners_query_name}", fragment_paths)

      post_graphql(query, current_user: admin, variables: {})

      expect_graphql_errors_to_be_empty
    end
  end
end
