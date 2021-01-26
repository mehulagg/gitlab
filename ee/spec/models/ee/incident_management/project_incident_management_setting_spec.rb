# frozen_string_literal: true

require 'spec_helper'

RSpec.describe EE::IncidentManagement::ProjectIncidentManagementSetting do
  let_it_be(:project) { create(:project, :repository, create_templates: :issue) }

  describe 'Validations' do
    describe 'validate SLA settings' do
      subject { build(:project_incident_management_setting, sla_timer: sla_timer) }

      describe '#sla_timer_minutes' do
        context 'sla_timer is disabled' do
          let(:sla_timer) { false }

          it { is_expected.not_to validate_presence_of(:sla_timer_minutes) }
        end

        context 'sla_timer is enabled' do
          let(:sla_timer) { true }

          it { is_expected.to validate_numericality_of(:sla_timer_minutes).is_greater_than_or_equal_to(15) }
          it { is_expected.to validate_numericality_of(:sla_timer_minutes).is_less_than_or_equal_to(1.year / 1.minute) } # 1 year
        end
      end
    end
  end
end
