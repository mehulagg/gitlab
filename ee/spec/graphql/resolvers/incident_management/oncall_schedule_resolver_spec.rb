# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IncidentManagement::OncallScheduleResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }
  let_it_be(:oncall_schedule_2) { create(:incident_management_oncall_schedule, project: project) }

  subject { sync(resolve_oncall_schedules) }

  before do
    stub_licensed_features(oncall_schedules: true)
    project.add_maintainer(current_user)
  end

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::IncidentManagement::OncallScheduleType.connection_type)
  end

  it 'returns on-call schedules' do
    is_expected.to contain_exactly(oncall_schedule, oncall_schedule_2)
  end

  context 'finding by iid' do
    it 'by single iid' do
      expect(resolve_oncall_schedules(iids: [oncall_schedule.iid])).to contain_exactly(oncall_schedule)
    end

    it 'by multiple iids' do
      expect(resolve_oncall_schedules(iids: [oncall_schedule.iid, oncall_schedule_2.iid])).to contain_exactly(oncall_schedule, oncall_schedule_2)
    end

    it 'by no iids' do
      expect(resolve_oncall_schedules(iids: [])).to match_array([])
    end
  end

  private

  def resolve_oncall_schedules(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
