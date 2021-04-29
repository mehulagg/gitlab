# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::VulnerabilitiesHistoryResolver do
  include GraphqlHelpers

  subject { resolve(described_class, obj: group, args: args, ctx: { current_user: user }) }

  let_it_be(:group) { create(:group) }
  let_it_be(:project) { create(:project, namespace: group) }
  let_it_be(:user) { create(:user) }

  describe '#resolve' do
    let(:args) { { start_date: Date.parse('2019-10-15'), end_date: Date.parse('2019-10-21') } }

    it "fetches historical vulnerability data from the start date to the end date" do
      travel_to(Date.parse('2019-10-31')) do
        create(:vulnerability, :critical, created_at: 15.days.ago, dismissed_at: 10.days.ago, project: project)
        create(:vulnerability, :high, created_at: 15.days.ago, dismissed_at: 11.days.ago, project: project)
        create(:vulnerability, :critical, created_at: 14.days.ago, resolved_at: 12.days.ago, project: project)

        ordered_history = subject.sort_by { |count| [count['day'], count['severity']] }

        expect(ordered_history.to_json).to eq([
          { 'day' => '2019-10-16', 'severity' => 'critical', 'count' => 1, 'id' => nil },
          { 'day' => '2019-10-16', 'severity' => 'high', 'count' => 1, 'id' => nil },
          { 'day' => '2019-10-17', 'severity' => 'critical', 'count' => 2, 'id' => nil },
          { 'day' => '2019-10-17', 'severity' => 'high', 'count' => 1, 'id' => nil },
          { 'day' => '2019-10-18', 'severity' => 'critical', 'count' => 2, 'id' => nil },
          { 'day' => '2019-10-18', 'severity' => 'high', 'count' => 1, 'id' => nil },
          { 'day' => '2019-10-19', 'severity' => 'critical', 'count' => 1, 'id' => nil },
          { 'day' => '2019-10-19', 'severity' => 'high', 'count' => 1, 'id' => nil },
          { 'day' => '2019-10-20', 'severity' => 'critical', 'count' => 1, 'id' => nil }
        ].to_json)
      end
    end

    context 'when given more than 10 days' do
      let(:args) { { start_date: Date.parse('2019-10-11'), end_date: Date.parse('2019-10-21') } }

      it 'raises an error stating that no more than 10 days can be requested' do
        expect { subject }.to raise_error(::Vulnerability::TooManyDaysError, 'Cannot fetch counts for more than 10 days')
      end
    end
  end
end
