# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallSchedulePolicy do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:oncall_schedule) { create(:incident_management_oncall_schedule, project: project) }

  subject(:policy) { described_class.new(user, oncall_schedule) }

  describe 'rules' do
    it { is_expected.to be_disallowed :read_incident_management_oncall_schedule }

    context 'when maintainer' do
      before do
        project.add_maintainer(user)
      end

      it { is_expected.to be_allowed :read_incident_management_oncall_schedule }
    end
  end
end
