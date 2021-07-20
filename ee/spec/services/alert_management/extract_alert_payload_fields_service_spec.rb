# frozen_string_literal: true

require 'spec_helper'

RSpec.describe AlertManagement::ExtractAlertPayloadFieldsService do
  let_it_be_with_reload(:project) { create(:project) }
  let_it_be(:user_with_permissions) { create(:user) }
  let_it_be(:user_without_permissions) { create(:user) }
  let_it_be(:user) { user_with_permissions }

  let(:payload) { { foo: 'bar' } }
  let(:payload_json) { Gitlab::Json.generate(payload) }
  let(:params) { { payload: payload_json } }

  let(:service) do
    described_class.new(container: project, current_user: user, params: params)
  end

  subject(:response) { service.execute }

  context 'with license' do
    before do
      stub_licensed_features(multiple_alert_http_integrations: true)
    end

    context 'with permissions' do
      before do
        project.add_maintainer(user_with_permissions)
      end

      context 'when payload is valid JSON' do
        context 'when payload has an acceptable size' do
          it 'responds with success' do
            is_expected.to be_success
          end

          it 'returns parsed fields' do
            fields = response.payload[:payload_alert_fields]
            field = fields.first

            expect(fields.count).to eq(1)
            expect(field.label).to eq('foo')
            expect(field.type).to eq('string')
            expect(field.path).to eq(%w[foo])
          end
        end

        context 'when limits are exceeded' do
          before do
            allow(Gitlab::Utils::DeepSize)
                .to receive(:new)
                        .with(Gitlab::Json.parse(payload_json))
                        .and_return(double(valid?: false))
          end

          it 'returns payload size exceeded error' do
            is_expected.to be_error
            expect(response.message).to eq('Payload size exceeded')
          end
        end
      end

      context 'when payload is not a valid JSON' do
        let(:payload) { 'not a JSON' }

        it 'returns payload parse failure error' do
          is_expected.to be_error
          expect(response.message).to eq('Failed to parse payload')
        end
      end
    end

    context 'without permissions' do
      let_it_be(:user) { user_without_permissions }

      it 'returns insufficient permissions error' do
        is_expected.to be_error
        expect(response.message).to eq('Insufficient permissions')
      end
    end
  end
end
