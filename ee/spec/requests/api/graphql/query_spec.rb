# frozen_string_literal: true

require 'spec_helper'

describe 'Query' do
  include GraphqlHelpers

  let_it_be(:project) { create(:project) }
  let_it_be(:issue) { create(:issue, project: project) }
  let_it_be(:developer) { create(:user) }
  let(:current_user) { developer }

  describe '.designManagement' do
    include DesignManagementTestHelpers

    let_it_be(:version) { create(:design_version, issue: issue) }
    let_it_be(:design) { version.designs.first }
    let(:query_result) { graphql_data.dig(*path) }
    let(:query) { graphql_query_for(:design_management, nil, dm_fields) }

    before do
      enable_design_management
      project.add_developer(developer)
      post_graphql(query, current_user: current_user)
    end

    shared_examples 'a query that needs authorization' do
      context 'the current user is not able to read designs' do
        let(:current_user) { create(:user) }

        it 'does not retrieve the record' do
          expect(query_result).to be_nil
        end

        it 'raises an error' do
          expect(graphql_errors).to include(
            a_hash_including('message' => a_string_matching(%r{you don't have permission}))
          )
        end
      end
    end

    describe '.version' do
      let(:path) { %w[designManagement version] }

      let(:dm_fields) do
        query_graphql_field(:version, { 'id' => global_id_of(version) }, 'id sha')
      end

      it_behaves_like 'a working graphql query'
      it_behaves_like 'a query that needs authorization'

      context 'the current user is able to read designs' do
        it 'fetches the expected data' do
          expect(query_result).to eq('id' => global_id_of(version), 'sha' => version.sha)
        end
      end
    end

    describe '.designAtVersion' do
      let_it_be(:design_at_version) do
        ::DesignManagement::DesignAtVersion.new(design: design, version: version)
      end

      let(:path) { %w[designManagement designAtVersion] }

      let(:dm_fields) do
        query_graphql_field(:design_at_version, { 'id' => global_id_of(design_at_version) }, <<~FIELDS)
          id
          filename
          version { id sha }
          design { id }
          issue { title iid }
          project { id fullPath }
        FIELDS
      end

      it_behaves_like 'a working graphql query'
      it_behaves_like 'a query that needs authorization'

      context 'the current user is able to read designs' do
        it 'fetches the expected data, including the correct associations' do
          expect(query_result).to eq(
            'id' => global_id_of(design_at_version),
            'filename' => design_at_version.design.filename,
            'version' => { 'id' => global_id_of(version), 'sha' => version.sha },
            'design'  => { 'id' => global_id_of(design) },
            'issue'   => { 'title' => issue.title, 'iid' => issue.iid.to_s },
            'project' => { 'id' => global_id_of(project), 'fullPath' => project.full_path }
          )
        end
      end
    end
  end

  describe '.vulnerabilitiesCountByDayAndSeverity' do
    let(:query_result) { graphql_data.dig('vulnerabilitiesCountByDayAndSeverity', 'nodes') }

    let(:query) do
      graphql_query_for(
        :vulnerabilitiesCountByDayAndSeverity,
        {
          start_date: Date.parse('2019-10-15').iso8601,
          end_date: Date.parse('2019-10-21').iso8601
        },
        history_fields
      )
    end

    let(:history_fields) do
      query_graphql_field(:nodes, nil, <<~FIELDS)
        count
        day
        severity
      FIELDS
    end

    it "fetches historical vulnerability data from the start date to the end date for projects on the current user's instance security dashboard" do
      Timecop.freeze(Time.zone.parse('2019-10-31')) do
        current_user.security_dashboard_projects << project
        project.add_developer(developer)

        create(:vulnerability, :critical, created_at: 15.days.ago, dismissed_at: 10.days.ago, project: project)
        create(:vulnerability, :high, created_at: 15.days.ago, dismissed_at: 11.days.ago, project: project)
        create(:vulnerability, :critical, created_at: 14.days.ago, resolved_at: 12.days.ago, project: project)

        post_graphql(query, current_user: current_user)

        ordered_history = query_result.sort_by { |count| [count['day'], count['severity']] }

        expect(ordered_history).to eq([
          { 'severity' => 'CRITICAL', 'day' => '2019-10-16', 'count' => 1 },
          { 'severity' => 'HIGH', 'day' => '2019-10-16', 'count' => 1 },
          { 'severity' => 'CRITICAL', 'day' => '2019-10-17', 'count' => 2 },
          { 'severity' => 'HIGH', 'day' => '2019-10-17', 'count' => 1 },
          { 'severity' => 'CRITICAL', 'day' => '2019-10-18', 'count' => 2 },
          { 'severity' => 'HIGH', 'day' => '2019-10-18', 'count' => 1 },
          { 'severity' => 'CRITICAL', 'day' => '2019-10-19', 'count' => 1 },
          { 'severity' => 'HIGH', 'day' => '2019-10-19', 'count' => 1 },
          { 'severity' => 'CRITICAL', 'day' => '2019-10-20', 'count' => 1 }
        ])
      end
    end
  end
end
