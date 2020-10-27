# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::TokenRevocationService, '#execute' do
  let_it_be(:revocable_keys) { [{
      "type": "aws_key_id",
      "token": "AKIASOMEAWSACCESSKEY",
      "location": "https://mywebsite.com/some-repo/blob/abcdefghijklmnop/compromisedfile.java"

    },
    {
      "type": "aws_secret",
      "token": "some_aws_secret_key_some_aws_secret_key_",
      "location": "https://mywebsite.com/some-repo/blob/abcdefghijklmnop/compromisedfile.java"

    },
    {
      "type": "aws_secret",
      "token": "another_aws_secret_key_another_secret_key",
      "location": "https://mywebsite.com/some-repo/blob/abcdefghijklmnop/compromisedfile.java"

    }
    ] }

  let_it_be(:token_revocation_url) { "https://myhost.com/api/v1/revoke" }

  subject { described_class.new(revocable_keys: revocable_keys).execute }

  before do
    allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_url).and_return(token_revocation_url)
    allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_token).and_return("token")
  end

  context "when revocation service is disabled" do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_enabled).and_return(false)
    end

    specify { expect(subject).to eql({:message => "Token revocation is disabled", :status => :error}) }
  end

  context "when revocation service is enabled" do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_enabled).and_return(true)

      stub_request(:post, token_revocation_url)
        .with(body: revocable_keys.to_json)
        .to_return(
          status: 200,
          headers: { 'Content-Type' => 'application/json' },
          body: {}.to_json
      )
    end

    specify { expect(subject[:status]).to be(:success) }
  end

end
