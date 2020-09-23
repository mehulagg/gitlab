# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Releases (JavaScript fixtures)' do
  include JavaScriptFixturesHelpers

  let_it_be(:admin) { create(:admin) }
  let_it_be(:project) { create(:project, :repository, path: 'releases-project') }

  let_it_be(:release) do
    create(:release,
           :with_evidence,
           :with_milestones,
           milestones_count: 2,
           project: project,
           tag: 'v1.1',
           name: 'The first release',
           description: 'Best. Release. **Ever.** :rocket:',
           created_at: Time.zone.parse('2018-12-3'),
           released_at: Time.zone.parse('2018-12-10'))
  end

  let_it_be(:other_link) do
    create(:release_link,
           release: release,
           name: 'linux-amd64 binaries',
           filepath: '/binaries/linux-amd64',
           url: 'https://downloads.example.com/bin/gitlab-linux-amd64')
  end

  let_it_be(:runbook_link) do
    create(:release_link,
           release: release,
           name: 'Runbook',
           url: 'https://example.com/runbook',
           link_type: :runbook)
  end

  before(:all) do
    clean_frontend_fixtures('api/releases/')
    clean_frontend_fixtures('graphql/releases/')
  end

  after(:all) do
    remove_repository(project)
  end

  # describe API::Releases, '(JavaScript fixtures)', type: :request do
  #   include ApiHelpers

  #   it 'api/releases/release.json' do
  #     get api("/projects/#{project.id}/releases/#{release.tag}", admin)

  #     expect(response).to be_successful
  #   end
  # end

  describe '~/releases/queries/all_releases.query.graphql (JavaScript fixtures)', type: :request do
    include ApiHelpers
    include GraphqlHelpers

    let(:query) do
      graphql_query_for(:project, { fullPath: project.full_path },
      %{
        releases {
          count
          nodes {
            tagName
            tagPath
            name
            commit {
              sha
            }
            assets {
              count
              sources {
                nodes {
                  url
                }
              }
            }
            evidences {
              nodes {
                sha
              }
            }
            links {
              selfUrl
              mergeRequestsUrl
              issuesUrl
            }
          }
        }
      })
    end

    # let(:response) { graphql_data }

    before do
      post_graphql(query, current_user: admin)
    end

    it 'graphql/releases/queries/all_releases.query.json' do
      expect_graphql_errors_to_be_empty
    end
  end
end
