# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MemberUserEntity do
  include OncallHelpers

  let_it_be_with_reload(:user) { create(:user) }

  let(:entity) { described_class.new(user, source: source) }
  let(:entity_hash) { entity.as_json }
  let(:source) { nil }

  it 'matches json schema' do
    expect(entity.to_json).to match_schema('entities/member_user')
  end

  context 'with oncall schedules' do
    let_it_be(:group) { create(:group) }
    let_it_be(:project_1) { create(:project, group: group )}
    let_it_be(:project_2) { create(:project, group: group )}

    let_it_be(:oncall_schedule_1) { create_schedule_with_user(project_1, user) }
    let_it_be(:oncall_schedule_2) { create_schedule_with_user(project_2, user) }

    it 'returns an empty array if no source option is given' do
      expect(entity_hash[:oncall_schedules]).to eq []
    end

    context 'source is project' do
      let(:source) { project_1 }

      it 'correctly exposes `oncall_schedules`' do
        expect(entity_hash[:oncall_schedules]).to contain_exactly(schedule_hash(oncall_schedule_1))
      end
    end

    context 'source is group' do
      let(:source) { group }

      it 'correctly exposes `oncall_schedules`' do
        expect(entity_hash[:oncall_schedules]).to contain_exactly(schedule_hash(oncall_schedule_1), schedule_hash(oncall_schedule_2))
      end
    end

    private

    def schedule_hash(schedule)
      schedule_url = Gitlab::Routing.url_helpers.project_incident_management_oncall_schedules_url(schedule.project)
      project_url = Gitlab::Routing.url_helpers.project_url(schedule.project)
      {
        name: schedule.name,
        project_name: schedule.project.name,
        schedule_url: schedule_url,
        project_url: project_url
      }
    end
  end
end
