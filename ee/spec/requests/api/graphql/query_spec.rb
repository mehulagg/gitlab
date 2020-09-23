# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Query' do
  include GraphqlHelpers

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
        project = create(:project)
        current_user = create(:user)
        current_user.security_dashboard_projects << project
        project.add_developer(current_user)

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
