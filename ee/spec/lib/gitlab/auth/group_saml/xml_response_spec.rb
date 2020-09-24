# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::GroupSaml::XmlResponse do
  let(:saml_provider) { create(:saml_provider) }
  let(:group) { saml_provider.group }
  let(:raw_response) do
    fixture = File.read('ee/spec/fixtures/saml/response.xml')
    Base64.encode64(fixture)
  end

  subject { described_class.new(raw_response: raw_response, group: group) }

  it 'configures ruby-saml using configured settings' do
    expect(subject.saml_response.settings.idp_cert_fingerprint).to eq saml_provider.certificate_fingerprint
  end

  it 'validates xml according to SAML spec' do
    expect(subject.errors).to include(/Current time is on or after NotOnOrAfter condition/)
    expect(subject).not_to be_valid
  end

  it 'correctly detects fingerprint mismatch' do
    expect(subject.errors).to include('Fingerprint mismatch')
  end

  describe 'attributes from encoded XML' do
    let(:name_id) { '_1f6fcf6be5e13b08b1e3610e7ff59f205fbd814f23' }
    let(:name_id_format) { 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient' }

    it 'retrieves NameID from XML' do
      expect(subject.name_id).to eq name_id
    end

    it 'retrieves NameID Format from XML' do
      expect(subject.name_id_format).to eq name_id_format
    end

    it 'provides decoded XML' do
      expect(subject.xml).to start_with('<?xml')
    end
  end
end
