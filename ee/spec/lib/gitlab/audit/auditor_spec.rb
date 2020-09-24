# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Audit::Auditor do
  let(:name) { 'play_with_project_settings' }
  let(:author) { build_stubbed(:user) }
  let(:scope) { build_stubbed(:group) }
  let(:target) { build_stubbed(:project) }
  let(:ip_address) { '192.168.8.8' }
  let(:context) { { name: name, author: author, scope: scope, target: target, ip_address: ip_address } }
  let(:add_message) { 'Added an interesting field from project Gotham' }
  let(:remove_message) { 'Removed an interesting field from project Gotham' }
  let(:operation) do
    proc do
      ::Gitlab::Audit::EventQueue.current << add_message
      ::Gitlab::Audit::EventQueue.current << remove_message
    end
  end

  let(:logger) { instance_spy(Gitlab::AuditJsonLogger) }

  subject(:auditor) { described_class }

  describe '.audit', :request_store do
    it 'interacts with the event queue in correct order', :aggregate_failures do
      allow(Gitlab::Audit::EventQueue).to receive(:begin!).and_call_original
      allow(Gitlab::Audit::EventQueue).to receive(:end!).and_call_original

      auditor.audit(context, &operation)

      expect(Gitlab::Audit::EventQueue).to have_received(:begin!).ordered
      expect(Gitlab::Audit::EventQueue).to have_received(:end!).ordered
    end

    it 'records audit events in correct order', :aggregate_failures do
      expect { auditor.audit(context, &operation) }.to change { AuditEvent.count }.by(2)

      event_messages = AuditEvent.all.order(created_at: :desc).map { |event| event.details[:custom_message] }

      expect(event_messages).to eq([add_message, remove_message])
    end

    it 'bulk-inserts audit events to database' do
      allow(AuditEvent).to receive(:bulk_insert!)

      auditor.audit(context, &operation)

      expect(AuditEvent).to have_received(:bulk_insert!)
    end

    it 'logs audit events to database', :aggregate_failures do
      auditor.audit(context, &operation)

      audit_event = AuditEvent.last

      expect(audit_event.author_id).to eq(author.id)
      expect(audit_event.entity_id).to eq(scope.id)
      expect(audit_event.entity_type).to eq(scope.class.name)
      expect(audit_event.details[:target_id]).to eq(target.id)
      expect(audit_event.details[:target_type]).to eq(target.class.name)
    end

    it 'logs audit events to file' do
      expect(::Gitlab::AuditJsonLogger).to receive(:build).and_return(logger)

      auditor.audit(context, &operation)

      expect(logger).to have_received(:info).exactly(2).times.with(
        hash_including(
          'author_id' => author.id,
          'author_name' => author.name,
          'entity_id' => scope.id,
          'entity_type' => scope.class.name,
          'details' => kind_of(Hash)
        )
      )
    end

    context 'when audit events are invalid' do
      before do
        allow(AuditEvent).to receive(:bulk_insert!).and_raise(ActiveRecord::RecordInvalid)
        allow(Gitlab::ErrorTracking).to receive(:track_exception)
      end

      it 'tracks error' do
        auditor.audit(context, &operation)

        expect(Gitlab::ErrorTracking).to have_received(:track_exception).with(
          kind_of(ActiveRecord::RecordInvalid),
          { audit_operation: name }
        )
      end

      it 'does not throw exception' do
        expect { auditor.audit(context, &operation) }.not_to raise_exception
      end
    end
  end
end
