# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Auth::U2fWebauthnConverter do
  let_it_be(:u2f_registration) do
    device = U2F::FakeU2F.new(FFaker::BaconIpsum.characters(5))
    create(:u2f_registration, name: 'u2f_device',
                              certificate: Base64.strict_encode64(device.cert_raw),
                              key_handle: U2F.urlsafe_encode64(device.key_handle_raw),
                              public_key: Base64.strict_encode64(device.origin_public_key_raw))
  end

  it 'converts u2f registration' do
    converted_webauthn = described_class.new(u2f_registration).convert

    expected_credential = convert_credential_for(u2f_registration)
    expect(converted_webauthn).to include(expected_credential)
  end

  def convert_credential_for(u2f_registration)
    credential = WebAuthn::U2fMigrator.new(
      app_id: Gitlab.config.gitlab.url,
      certificate: u2f_registration.certificate,
      key_handle: u2f_registration.key_handle,
      public_key: u2f_registration.public_key,
      counter: u2f_registration.counter
    ).credential

    {
      credential_xid: Base64.strict_encode64(credential.id),
      public_key: Base64.strict_encode64(credential.public_key),
      counter: u2f_registration.counter,
      name: u2f_registration.name,
      user_id: u2f_registration.user_id,
      u2f_registration_id: u2f_registration.id
    }
  end
end
