# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Kerberos::Authentication do
  let(:user) { create(:omniauth_user, provider: :kerberos, extern_uid: 'gitlab@FOO.COM') }
  let(:login) { 'john' }
  let(:password) { 'password' }

  before do
    described_class.krb5_class # eager load the krb5_auth gem
  end

  describe '.kerberos_default_realm' do
    it "returns the default realm exposed by the Kerberos library" do
      allow_next_instance_of(::Krb5Auth::Krb5) do |instance|
        allow(instance).to receive_messages(get_default_realm: "FOO.COM")
      end

      expect(described_class.kerberos_default_realm).to eq("FOO.COM")
    end
  end

  describe '.login' do
    before do
      allow(Devise).to receive_messages(omniauth_providers: [:kerberos])
      user # make sure user is instanciated
    end

    it "finds the user if authentication is successful (login without kerberos realm)" do
      allow_next_instance_of(::Krb5Auth::Krb5) do |instance|
        allow(instance).to receive_messages(get_init_creds_password: true, get_default_principal: 'gitlab@FOO.COM')
      end

      expect(described_class.login('gitlab', password)).to be_truthy
    end

    it "finds the user if authentication is successful (login with a kerberos realm)" do
      allow_next_instance_of(::Krb5Auth::Krb5) do |instance|
        allow(instance).to receive_messages(get_init_creds_password: true, get_default_principal: 'gitlab@FOO.COM')
      end

      expect(described_class.login('gitlab@FOO.COM', password)).to be_truthy
    end

    it "returns false if there is no such user in kerberos" do
      kerberos_login = "some-login"
      allow_next_instance_of(::Krb5Auth::Krb5) do |instance|
        allow(instance).to receive_messages(get_init_creds_password: true, get_default_principal: 'some-login@FOO.COM')
      end

      expect(described_class.login(kerberos_login, password)).to be_falsy
    end
  end
end
