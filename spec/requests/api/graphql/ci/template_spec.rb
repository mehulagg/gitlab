# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Querying CI template' do
  include GraphqlHelpers

  let(:project) { create(:project, :public) }
  let(:user) { create(:user) }

  let(:query) do
    <<~QUERY
    {
      project(fullPath: "#{project.full_path}") {
        name
        ciTemplate(name: "Android") {
          name
          content
        }
      }
    }
    QUERY
  end

  before do
    post_graphql(query, current_user: user)
  end

  it_behaves_like 'a working graphql query'

  it 'returns correct data' do
    expect(graphql_data['project']['ciTemplate']['name']).not_to be_blank
    expect(graphql_data['project']['ciTemplate']['content']).not_to be_blank
  end
end
