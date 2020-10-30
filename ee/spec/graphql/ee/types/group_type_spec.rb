# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GitlabSchema.types['Group'] do
  describe 'nested epic request' do
    it { expect(described_class).to have_graphql_field(:epicsEnabled) }
    it { expect(described_class).to have_graphql_field(:epics) }
    it { expect(described_class).to have_graphql_field(:epic) }
  end

  it { expect(described_class).to have_graphql_field(:iterations) }
  it { expect(described_class).to have_graphql_field(:groupTimelogsEnabled) }
  it { expect(described_class).to have_graphql_field(:timelogs, complexity: 5) }
  it { expect(described_class).to have_graphql_field(:vulnerabilities) }
  it { expect(described_class).to have_graphql_field(:vulnerability_scanners) }
  it { expect(described_class).to have_graphql_field(:vulnerabilities_count_by_day_and_severity) }
  it { expect(described_class).to have_graphql_field(:vulnerability_grades) }
  it { expect(described_class).to have_graphql_field(:code_coverage_activities) }

  describe 'timelogs field' do
    subject { described_class.fields['timelogs'] }

    it 'finds timelogs between start time and end time' do
      is_expected.to have_graphql_arguments(:start_time, :end_time, :start_date, :end_date, :after, :before, :first, :last)
      is_expected.to have_graphql_resolver(Resolvers::TimelogResolver)
      is_expected.to have_non_null_graphql_type(Types::TimelogType.connection_type)
    end
  end

  describe 'vulnerabilities' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project) { create(:project, namespace: group) }
    let_it_be(:user) { create(:user) }
    let_it_be(:vulnerability) do
      create(:vulnerability, :detected, :critical, project: project, title: 'A terrible one!')
    end

    let_it_be(:query) do
      %(
        query {
          group(fullPath: "#{group.full_path}") {
            name
            vulnerabilities {
              nodes {
                title
                severity
                state
              }
            }
          }
        }
      )
    end

    before do
      stub_licensed_features(security_dashboard: true)

      group.add_developer(user)
    end

    subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

    it "returns the vulnerabilities for all projects in the group and its subgroups" do
      vulnerabilities = subject.dig('data', 'group', 'vulnerabilities', 'nodes')

      expect(vulnerabilities.count).to be(1)
      expect(vulnerabilities.first['title']).to eq('A terrible one!')
      expect(vulnerabilities.first['state']).to eq('DETECTED')
      expect(vulnerabilities.first['severity']).to eq('CRITICAL')
    end
  end

  describe 'codeCoverageActivities' do
    let(:group) { create(:group) }
    let(:user) { create(:user) }
    let(:start_date) { 1.day.ago.to_date.to_s }
    let(:query) do
      %(
        query {
          group(fullPath: "#{group.full_path}") {
            codeCoverageActivities(startDate: "#{start_date}") {
              nodes {
                averageCoverage
              }
            }
          }
        }
      )
    end

    context 'when group_coverage_data_report flag is disabled' do
      subject { GitlabSchema.execute(query, context: { current_user: user }).as_json }

      it 'returns a graphQL error field does not exist' do
        stub_feature_flags(group_coverage_data_report: false)

        expected_message = "Field 'codeCoverageActivities' doesn't exist on type 'Group'"

        expect(subject.dig('errors').first.dig('message')).to eq(expected_message)
      end
    end
  end
end
