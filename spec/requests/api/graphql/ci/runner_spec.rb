# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query.runner(id)' do
  include GraphqlHelpers

  let_it_be(:user) { create_default(:user, :admin) }

  let(:active_runner) do
    create(:ci_runner, :instance, description: 'Runner 1', contacted_at: 2.hours.ago,
           active: true, version: 'adfe156', revision: 'a', locked: true, ip_address: '127.0.0.1', maximum_timeout: 600,
           access_level: 0, tag_list: %w[tag1 tag2], run_untagged: true)
  end

  let(:inactive_runner) do
    create(:ci_runner, :instance, description: 'Runner 2', contacted_at: 1.day.ago, active: false,
           version: 'adfe157', revision: 'b', ip_address: '10.10.10.10', access_level: 1, run_untagged: true)
  end

  def get_runner(id)
    case id
    when :active_runner
      active_runner
    when :inactive_runner
      inactive_runner
    end
  end

  shared_examples 'runner details fetch' do |runner_id|
    let(:query) do
      wrap_fields(query_graphql_path(query_path, all_graphql_fields_for('CiRunner')))
    end

    let(:query_path) do
      [
        [:runner, { id: get_runner(runner_id).id }]
      ]
    end

    it 'retrieves expected fields' do
      post_graphql(query, current_user: user)

      runner_data = graphql_data_at(:runner)
      expect(runner_data).not_to be_nil

      runner = get_runner(runner_id)
      expect(runner_data).to match a_hash_including(
        'id' => "gid://gitlab/Ci::Runner/#{runner.id}",
        'description' => runner.description,
        'lastContactAt' => runner.contacted_at&.iso8601,
        'version' => runner.version,
        'shortSha' => runner.short_sha,
        'revision' => runner.revision,
        'locked' => runner.locked,
        'active' => runner.active,
        'status' => runner.status.to_s.upcase,
        'maximumTimeout' => runner.maximum_timeout,
        'accessLevel' => runner.access_level.to_s.upcase,
        'runUntagged' => runner.run_untagged,
        'ipAddress' => runner.ip_address,
        'runnerType' => 'INSTANCE_TYPE'
      )
      expect(runner_data['tagList']).to match_array runner.tag_list
    end
  end

  describe 'for active runner' do
    it_behaves_like 'runner details fetch', :active_runner
  end

  describe 'for inactive runner' do
    it_behaves_like 'runner details fetch', :inactive_runner
  end
end
