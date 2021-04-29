# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AppSec::Dast::ScannerProfiles::UpdateAuditEventWorker do
  let_it_be(:project) { create(:project) }
  let_it_be(:user) { create(:user) }

  let!(:old_params) { profile.attributes.symbolize_keys }

  let(:job_args) { [user.id, project.id, profile.id, params, old_params] }
  let(:params) { { name: 'a modified DAST scanner profile' } }
  let(:profile) { create(:dast_scanner_profile, name: 'a DAST scanner profile') }

  before do
    stub_licensed_features(extended_audit_events: true)

    project.add_developer(user)
    profile.update!(name: 'a modified DAST scanner profile')
  end

  it_behaves_like 'an idempotent worker'

  describe '#perform' do
    it 'creates audit events for each updated property', :aggregate_failures do
      subject.perform(*job_args)

      events = AuditEvent.all
      expect(events.count).to be(1)

      event = events.last
      expect(event.author).to eq(user)
      expect(event.entity).to eq(project)
      expect(event.target_id).to eq(profile.id)
      expect(event.target_type).to eq('DastScannerProfile')
      expect(event.target_details).to eq(profile.name)
      expect(event.details).to eq({
        change: 'DAST scanner profile name',
        from: 'a DAST scanner profile',
        to: 'a modified DAST scanner profile',
        target_id: profile.id,
        target_type: 'DastScannerProfile',
        target_details: 'a modified DAST scanner profile'
      })
    end
  end
end
