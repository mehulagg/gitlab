# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Users::BuildService do
  describe '#execute' do
    let(:params) do
      { name: 'John Doe', username: 'jduser', email: 'jd@example.com', password: 'mydummypass' }
    end

    context 'with an admin user' do
      let!(:admin_user) { create(:admin) }
      let(:service) { described_class.new(admin_user, ActionController::Parameters.new(params).permit!) }

      context 'allowed params' do
        let(:provider) { create(:saml_provider) }
        let(:identity_params) { { extern_uid: 'uid', provider: 'group_saml', saml_provider_id: provider.id } }

        before do
          params.merge!(identity_params)
        end

        context 'with identity' do
          it 'sets all allowed attributes' do
            expect(Identity).to receive(:new).with(hash_including(identity_params)).and_call_original
            expect(ScimIdentity).not_to receive(:new)

            service.execute
          end
        end

        context 'with scim identity' do
          before do
            params.merge!(scim_identity_params)
          end
          let_it_be(:scim_identity_params) { { extern_uid: 'uid', provider: 'group_scim', group_id: 1 } }

          it 'passes allowed attributes to both scim and saml identity' do
            scim_identity_params.delete(:provider)

            expect(ScimIdentity).to receive(:new).with(hash_including(scim_identity_params)).and_call_original
            expect(Identity).to receive(:new).with(hash_including(identity_params)).and_call_original

            service.execute
          end
        end
      end

      context 'smartcard authentication enabled' do
        before do
          allow(Gitlab::Auth::Smartcard).to receive(:enabled?).and_return(true)
        end

        context 'smartcard params' do
          let(:subject) { '/O=Random Corp Ltd/CN=gitlab-user/emailAddress=gitlab-user@random-corp.org' }
          let(:issuer) { '/O=Random Corp Ltd/CN=Random Corp' }
          let(:smartcard_identity_params) do
            { certificate_subject: subject, certificate_issuer: issuer }
          end

          before do
            params.merge!(smartcard_identity_params)
          end

          it 'sets smartcard identity attributes' do
            expect(SmartcardIdentity).to(
              receive(:new)
                .with(hash_including(issuer: issuer, subject: subject))
                .and_call_original)

            service.execute
          end
        end

        context 'missing smartcard params' do
          it 'works as expected' do
            expect { service.execute }.not_to raise_error
          end
        end
      end
    end
  end
end
