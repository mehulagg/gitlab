# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEvents::RepositoryPushAuditEventService do
  let(:user) { create(:user, :with_sign_ins) }
  let(:entity) { create(:project) }
  let(:entity_type) { 'Project' }
  let(:target_ref) { 'refs/heads/master' }
  let(:from) { 'b6bce79c3a8cb367877b53e315799b69acb700d7' }
  let(:to) { 'a7bce79c3a8cb367877b53e315799b69acb700fo' }
  let(:service) { described_class.new(user, entity, target_ref, from, to) }

  describe '#attributes' do
    before do
      stub_licensed_features(admin_audit_log: true)
    end

    let(:timestamp) { Time.zone.local(2019, 10, 10) }
    let(:attrs) do
      {
        author_id: user.id,
        author_name: user.name,
        entity_id: entity.id,
        entity_type: entity_type,
        created_at: timestamp,
        ip_address: '127.0.0.1',
        details: {
          updated_ref: updated_ref,
          author_name: user.name,
          from: 'b6bce79c',
          to: 'a7bce79c',
          target_details: entity.full_path
        }.to_yaml
      }
    end

    context 'when branch push' do
      let(:target_ref) { 'refs/heads/master' }
      let(:updated_ref) { 'master' }

      it 'returns audit event attributes' do
        travel_to(timestamp) do
          expect(service.attributes).to eq(attrs)
        end
      end
    end

    context 'when tag push' do
      let(:target_ref) { 'refs/tags/v1.0' }
      let(:updated_ref) { 'v1.0' }

      it 'returns audit event attributes' do
        travel_to(timestamp) do
          expect(service.attributes).to eq(attrs)
        end
      end
    end
  end

  describe '#enabled?' do
    let(:target_ref) { 'refs/tags/v1.0' }

    subject { service.enabled? }

    context 'when not licensed and not enabled' do
      before do
        stub_licensed_features(audit_events: false,
                               extended_audit_events: false,
                               admin_audit_log: false)

        stub_feature_flags(repository_push_audit_event: false)
      end

      it { is_expected.to be(false) }
    end

    context 'when licensed but not enabled' do
      before do
        stub_licensed_features(audit_events: true,
                               extended_audit_events: false,
                               admin_audit_log: false)

        stub_feature_flags(repository_push_audit_event: false)
      end

      it { is_expected.to be(false) }
    end

    context 'when licensed and enabled' do
      before do
        stub_licensed_features(audit_events: true,
                               extended_audit_events: false,
                               admin_audit_log: false)

        stub_feature_flags(repository_push_audit_event: true)
      end

      it { is_expected.to be(true) }
    end
  end
end
