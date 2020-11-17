# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ::Applications::CreateService do
  let(:user) { create(:user) }
  let(:params) { attributes_for(:application) }
  let(:request) { ActionController::TestRequest.new({ remote_ip: "127.0.0.1" }, ActionController::TestSession.new, nil) }

  subject { described_class.new(user, params) }

  it 'creates an audit log' do
    stub_licensed_features(extended_audit_events: true)

    expect { subject.execute(request) }.to change { AuditEvent.count }.by(1)
  end
end
