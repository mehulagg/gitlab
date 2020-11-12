# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Resolvers::IncidentManagement::OncallScheduleResolver do
  include GraphqlHelpers

  let_it_be(:current_user) { create(:user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }

  subject { sync(resolve_oncall_schedules) }

  specify do
    expect(described_class).to have_nullable_graphql_type(Types::IncidentManagement::OncallScheduleType.connection_type)
  end

  context 'user does not have permissions' do
    it { is_expected.to eq(IncidentManagement::OncallSchedule.none) }
  end

  context 'user has permissions' do
    before do
      project.add_maintainer(current_user)
    end

    it { is_expected.to contain_exactly(oncall_schedule) }

    # TODO: check feature flag
    # TODO: check license "Premium"
  end

  private

  def resolve_oncall_schedules(args = {}, context = { current_user: current_user })
    resolve(described_class, obj: project, args: args, ctx: context)
  end
end
