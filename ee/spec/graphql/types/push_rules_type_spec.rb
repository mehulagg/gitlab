# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['PushRules'] do
  include GraphqlHelpers

  let_it_be(:user) { create(:user) }
  let_it_be(:project) { create(:project, namespace: user.namespace) }
  let_it_be(:query) do
    %(
        query{
          project(fullPath:"#{project.full_path}"){
            pushRules {
              rejectUnsignedCommits
            }
          }
        }
      )
  end

  subject(:response) do
    gql_response = GitlabSchema.execute(query, context: { current_user: user })

    gql_response.dig(*%w[data project pushRules])
  end

  before do
    push_rule = create(:push_rule, project: project)
    push_rule.update!(reject_unsigned_commits: true)

    stub_licensed_features(reject_unsigned_commits: true)
  end

  it 'returns pushRules' do
    expect(response).to eq("rejectUnsignedCommits" => true)
  end

  context 'without reject_unsinged_commits license' do
    before do
      stub_licensed_features(reject_unsigned_commits: false)
    end

    it 'overwrites rejectUnsignedCommits as false' do
      expect(response).to eq("rejectUnsignedCommits" => false)
    end
  end
end
