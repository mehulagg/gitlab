# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Creation of a new release' do
  include GraphqlHelpers
  include Presentable

  let_it_be(:project) { create(:project, :public, :repository) }
  let_it_be(:milestone_12_3) { create(:milestone, project: project, title: '12.3') }
  let_it_be(:milestone_12_4) { create(:milestone, project: project, title: '12.4') }
  let_it_be(:reporter) { create(:user) }
  let_it_be(:developer) { create(:user) }

  let(:mutation_name) { :release_create }

  let(:tagName) { 'v1.1.0'}
  let(:ref) { 'master'}
  let(:name) { 'Version 1.0'}
  let(:description) { 'The first release :rocket' }
  let(:releasedAt) { '2018-12-10' }
  let(:milestones) { [milestone_12_3.title, milestone_12_4.title] }
  let(:assets) do
    {
      links: [
        {
          name: 'An asset link',
          url: 'https://gitlab.example.com/link',
          filepath: '/permanent/link',
          linkType: 'OTHER'
        }
      ]
    }
  end

  let(:mutation_arguments) do
    {
      projectPath: project.full_path,
      tagName: tagName,
      ref: ref,
      name: name,
      description: description,
      releasedAt: releasedAt,
      milestones: milestones,
      assets: assets
    }
  end

  let(:mutation) do
    graphql_mutation(mutation_name, mutation_arguments, <<~FIELDS)
      release {
        tagName
        name
        description
        releasedAt
        createdAt
        milestones {
          nodes {
            title
          }
        }
        assets {
          links {
            nodes {
              name
              url
              linkType
              external
              directAssetUrl
            }
          }
        }
      }
      errors
    FIELDS
  end

  let(:create_release) { post_graphql_mutation(mutation, current_user: current_user) }
  let(:mutation_response) { graphql_mutation_response(mutation_name).with_indifferent_access }

  around do |example|
    freeze_time { example.run }
  end

  before do
    project.add_reporter(reporter)
    project.add_developer(developer)

    stub_default_url_options(host: 'www.example.com')
  end

  context 'when the current user has access to create releases' do
    let(:current_user) { developer }

    it 'returns no errors' do
      create_release

      expect(graphql_errors).not_to be_present
    end

    it 'returns the new release data' do
      create_release

      release = mutation_response[:release]
      expected_link = assets[:links].first
      expected_direct_asset_url = Gitlab::Routing.url_helpers.project_release_url(project, Release.find_by(tag: tagName)) << expected_link[:filepath]

      expect(release).to include(
        tagName: tagName,
        name: name,
        description: description,
        releasedAt: Time.parse(releasedAt).utc.iso8601,
        createdAt: Time.current.utc.iso8601,
        assets: {
          links: {
            nodes: [{
              name: expected_link[:name],
              url: expected_link[:url],
              linkType: expected_link[:linkType],
              external: true,
              directAssetUrl: expected_direct_asset_url
            }]
          }
        }
      )

      # Right now the milestones are returned in a non-deterministic order.
      # This `milestones` test should be moved up into the expect(release)
      # above (and `.to include` updated to `.to eq`) once
      # https://gitlab.com/gitlab-org/gitlab/-/issues/259012 is addressed.
      expect(release['milestones']['nodes']).to match_array([
        { 'title' => '12.4' },
        { 'title' => '12.3' }
      ])
    end
  end

  context "when the current user doesn't have access to create releases" do
    let(:current_user) { reporter }

    it 'returns an error' do
      create_release

      expect(graphql_errors).to be_present
    end
  end
end
