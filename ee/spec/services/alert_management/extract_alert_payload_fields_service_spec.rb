# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::ExtractAlertPayloadFieldsService do
  let(:project) { build_stubbed(:project) }
  let(:user) { build_stubbed(:user) }
  let(:params) { { payload: payload_json } }
  let(:payload_json) { Gitlab::Json.generate(payload) }
  let(:payload) { { foo: 'bar' } }

  let(:service) do
    described_class.new(container: project, current_user: user, params: params)
  end

  subject(:response) { service.execute }

  before do
    stub_licensed_features(multiple_alert_http_integrations: true)
    allow(user).to receive(:can?).with(:admin_operations, project).and_return(true)
  end

  it 'works' do
    expect(response).to be_success
  end

  context 'fails when limits are exceeded'
  context 'fails with invalid payload'
  context 'without license'
  context 'without feature flag'
  context 'without permission'
end
