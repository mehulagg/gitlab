# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ci::AuditVariableChangeService do
  subject(:execute) { service.execute }

  let_it_be(:user) { create(:user) }

  let(:group) { create(:group) }
  let(:variable) { create(:ci_group_variable) }

  let(:service) do
    described_class.new(
      container: group, current_user: user,
      params: { action: action, variable: variable }
    )
  end

  before do
    group.variables << variable
  end

  context 'when audits are available' do
    before do
      stub_licensed_features(audit_events: true)
    end

    context 'when creating variable' do
      let(:action) { :create }

      it 'logs audit event' do
        expect { execute }.to change(AuditEvent, :count).from(0).to(1)
      end

      it 'logs variable creation' do
        execute

        audit_event = AuditEvent.last.present

        expect(audit_event.action).to eq('Added ci group variable')
        expect(audit_event.target).to eq(variable.key)
      end
    end

    context 'when updating variable protection' do
      let(:action) { :update }

      before do
        variable.update!(protected: true)
      end

      it 'logs audit event' do
        expect { execute }.to change(AuditEvent, :count).from(0).to(1)
      end

      it 'logs variable protection update' do
        execute

        audit_event = AuditEvent.last.present

        expect(audit_event.action).to eq('Changed variable protection from false to true')
        expect(audit_event.target).to eq(variable.key)
      end
    end

    context 'when destroying variable' do
      let(:action) { :destroy }

      it 'logs audit event' do
        expect { execute }.to change(AuditEvent, :count).from(0).to(1)
      end

      it 'logs variable destruction' do
        execute

        audit_event = AuditEvent.last.present

        expect(audit_event.action).to eq('Removed ci group variable')
        expect(audit_event.target).to eq(variable.key)
      end
    end
  end

  context 'when audits are not available' do
    before do
      stub_licensed_features(audit_events: false)
    end

    context 'when creating variable' do
      let(:action) { :create }

      it 'does not log an audit event' do
        expect { execute }.not_to change(AuditEvent, :count).from(0)
      end
    end

    context 'when updating variable protection' do
      let(:action) { :update }

      before do
        variable.update!(protected: true)
      end

      it 'does not log an audit event' do
        expect { execute }.not_to change(AuditEvent, :count).from(0)
      end
    end

    context 'when destroying variable' do
      let(:action) { :destroy }

      it 'does not log an audit event' do
        expect { execute }.not_to change(AuditEvent, :count).from(0)
      end
    end
  end
end
