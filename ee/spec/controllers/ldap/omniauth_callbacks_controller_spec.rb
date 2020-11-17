# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Ldap::OmniauthCallbacksController do
  include_context 'Ldap::OmniauthCallbacksController'

  it "displays LDAP sync flash on first sign in" do
    post provider

    expect(flash[:notice]).to match(/LDAP sync in progress*/)
  end

  it "skips LDAP sync flash on subsequent sign ins" do
    user.update!(sign_in_count: 1)

    post provider

    expect(flash[:notice]).to eq nil
  end

  context 'access denied' do
    let(:valid_login?) { false }

    # This test used to pass on retry only, masking an actual bug. We want to
    # make sure it passes on the first try.
    it 'logs a failure event', retry: 0 do
      stub_licensed_features(extended_audit_events: true)

      expect { post provider }.to change(AuditEvent, :count).by(1)
    end
  end
end
