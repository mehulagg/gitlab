# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IncidentManagement::CreateSlaService do
  let_it_be(:project, reload: true) { create(:project) }
  let_it_be(:user) { create(:user) }
  let_it_be(:incident) { create(:incident, project: project) }

  before_all do
    project.add_maintainer(user)
  end

  before do
    project.clear_memoization(:licensed_feature_available)
    stub_licensed_features(incident_sla: true)
  end

  subject { described_class.new(incident, user, project).execute }

  shared_examples 'no incident sla created' do
    it 'does not create the incident sla' do
      expect { subject }.not_to change(IncidentManagement::IncidentSla, :count)
    end

    it { is_expected.to eq(nil) }
  end

  context 'incident setting not created' do
    it_behaves_like 'no incident sla created'
  end

  context 'incident setting exists' do
    let(:sla_timer) { true }
    let(:sla_timer_minutes) { 30 }
    let!(:setting) { create(:project_incident_management_setting, project: project, sla_timer: sla_timer, sla_timer_minutes: sla_timer_minutes) }

    context 'project does not have incident_sla feature' do
      before do
        stub_licensed_features(incident_sla: false)
      end

      it_behaves_like 'no incident sla created'
    end

    context 'sla timer setting is disabled' do
      let(:sla_timer) { false }

      it_behaves_like 'no incident sla created'
    end

    it 'creates the incident sla with the given offset', :aggregate_failures do
      incident_sla = nil
      expect { incident_sla = subject }.to change(IncidentManagement::IncidentSla, :count)

      offset_time = incident.created_at + setting.sla_timer_minutes.minutes
      expect(incident_sla.due_at).to eq(offset_time)
    end

    it { is_expected.to be_a(IncidentManagement::IncidentSla) }

    context 'errors when saving' do
      before do
        allow_next_instance_of(IncidentManagement::IncidentSla) do |incident_sla|
          allow(incident_sla).to receive(:save).and_return(false)

          errors = ActiveModel::Errors.new(incident_sla).tap { |e| e.add(:issue_id, "error message") }
          allow(incident_sla).to receive(:errors).and_return(errors)
        end
      end

      it 'does not create the incident sla' do
        expect { subject }.not_to change(IncidentManagement::IncidentSla, :count)
      end

      it { is_expected.to include(status: :error, message: ["Issue error message"]) }
    end
  end
end
