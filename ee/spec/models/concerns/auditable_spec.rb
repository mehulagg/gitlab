# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Auditable do
  let(:klazz) { Class.new { include Auditable } }

  subject(:instance) { klazz.new }

  describe '#push_audit_event', :request_store do
    let(:event) { 'Added a new cat to the house' }

    context 'when audit event queue is active' do
      before do
        allow(::Gitlab::Audit::EventQueue).to receive(:active?).and_return(true)
      end

      it 'add message to audit event queue' do
        instance.push_audit_event(event)

        expect(::Gitlab::Audit::EventQueue.current).to eq([event])
      end
    end

    context 'when audit event queue is not active' do
      before do
        allow(::Gitlab::Audit::EventQueue).to receive(:active?).and_return(false)
      end

      it 'does not add message to audit event queue' do
        instance.push_audit_event(event)

        expect(::Gitlab::Audit::EventQueue.current).to eq([])
      end
    end
  end

  describe '#audit_details' do
    it 'raises error to prompt for implementation' do
      expect { instance.audit_details }.to raise_error(/does not implement audit_details/)
    end
  end
end
