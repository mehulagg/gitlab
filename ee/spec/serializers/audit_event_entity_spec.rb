# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AuditEventEntity do
  let(:event) { create(:audit_event) }

  subject { described_class.new(event) }

  describe '.as_json' do
    it 'includes audit event attributes' do
      expect(subject.as_json.keys.sort).to eq([:action, :author, :date, :id, :ip_address, :object, :target])
    end
  end

  describe '@presenter' do
    it 'is only set once' do
      expect(AuditEventPresenter).to receive(:new)
                                         .with(event)
                                         .and_call_original
                                         .once
      subject.as_json
    end
  end
end
