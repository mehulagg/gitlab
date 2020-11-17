# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::OncallScheduleHelper do
  let_it_be(:project) { create(:project) }

  describe '#oncall_schedule_data' do
    subject(:data) { helper.oncall_schedule_data(project) }

    it 'returns on-call schedule data' do
      is_expected.to eq(
        'project-path' => project.full_path,
        'empty-oncall-schedule-svg-path' => helper.image_path('illustrations/empty-state/empty-on-call.svg')
      )
    end
  end
end
