# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::IdentityLinker do
  let(:user) { create(:user) }
  let(:provider) { 'group_saml' }
  let(:uid) { user.email }
  let(:in_response_to) { '12345' }
  let(:saml_response) { instance_double(OneLogin::RubySaml::Response, in_response_to: in_response_to) }
  let(:oauth) { OmniAuth::AuthHash.new(provider: provider, uid: uid, extra: { response_object: saml_response }) }
  let(:saml_provider) { create(:saml_provider) }
  let(:session) { {} }

  subject { described_class.new(user, oauth, session, saml_provider) }

  context 'linked identity exists' do
    let!(:identity) { user.identities.create!(provider: provider, extern_uid: uid, saml_provider: saml_provider) }

    it "doesn't create new identity" do
      expect { subject.link }.not_to change { Identity.count }
    end

    it "sets #changed? to false" do
      subject.link

      expect(subject).not_to be_changed
    end

    it 'adds user to group' do
      subject.link

      expect(saml_provider.group.member?(user)).to eq(true)
    end
  end

  context 'identity needs to be created' do
    context 'with identity provider initiated request' do
      it 'attempting to link accounts raises an exception' do
        expect { subject.link }.to raise_error(Gitlab::Auth::Saml::IdentityLinker::UnverifiedRequest)
      end
    end

    context 'with valid gitlab initiated request' do
      let(:session) { { 'last_authn_request_id' => in_response_to } }

      it 'creates linked identity' do
        expect { subject.link }.to change { user.identities.count }
      end

      it 'sets identity provider' do
        subject.link

        expect(user.identities.last.provider).to eq provider
      end

      it 'sets saml provider' do
        subject.link

        expect(user.identities.last.saml_provider).to eq saml_provider
      end

      it 'sets identity extern_uid' do
        subject.link

        expect(user.identities.last.extern_uid).to eq uid
      end

      it 'sets #changed? to true' do
        subject.link

        expect(subject).to be_changed
      end

      it 'adds user to group' do
        subject.link

        expect(saml_provider.group.member?(user)).to eq(true)
      end
    end
  end
end
