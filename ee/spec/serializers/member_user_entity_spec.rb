# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MemberUserEntity do
  let_it_be_with_reload(:user) { create(:user) }

  let(:entity) { described_class.new(user) }
  let(:entity_hash) { entity.as_json }

  it 'matches json schema' do
    expect(entity.to_json).to match_schema('entities/member_user')
  end

  context 'with oncall schedules' do
    let_it_be(:oncall_schedule) { create(:incident_management_oncall_participant, user: user).rotation.schedule }

    it 'correctly exposes `oncall_schedules`' do
      expect(entity_hash[:oncall_schedules]).to include(schedule_hash(oncall_schedule))
    end

    it 'exposed and de-dupes the schedules' do
      allow(user).to receive(:oncall_schedules).and_return([oncall_schedule, oncall_schedule])

      expect(entity_hash[:oncall_schedules].size).to eq(1)
      expect(entity_hash[:oncall_schedules]).to include(schedule_hash(oncall_schedule))
    end

    def schedule_hash(schedule)
      schedule_url = Gitlab::Routing.url_helpers.project_incident_management_oncall_schedules_url(schedule.project)
      project_url = Gitlab::Routing.url_helpers.project_url(schedule.project)
      {
        name: oncall_schedule.name,
        project_name: oncall_schedule.project.name,
        schedule_url: schedule_url,
        project_url: project_url
      }
    end
  end
end
