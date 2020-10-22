# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Security::TokenRevocationService, '#execute' do
  let_it_be(:revocation_token_types_url) { "https://myhost.com/api/v1/token_types" }
  let_it_be(:token_revocation_url) { "https://myhost.com/api/v1/revoke" }

  let_it_be(:revocable_keys) do
    [{
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
     }]
  end

  let_it_be(:revocable_token_types) do
    { "types": %w(aws_key_id aws_secret gcp_key_id gcp_secret) }
  end

  subject { described_class.new(revocable_keys: revocable_keys).execute }

  before do
    allow(::Gitlab::CurrentSettings).to receive(:secret_detection_revocation_token_types_url).and_return(revocation_token_types_url)
    allow(::Gitlab::CurrentSettings).to receive(:secret_detection_revocation_token_types_token).and_return("token1")
    allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_url).and_return(token_revocation_url)
    allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_token).and_return("token2")
  end

  context "when revocation token API returns a response with failure" do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_enabled).and_return(true)
      stub_revoke_token_api_with_failure
      stub_revocation_token_types_api_with_success
    end

    it "returns error" do
      expect(subject[:status]).to be(:error)
      expect(subject[:message]).to eql("Failed to revoke tokens")
    end
  end

  context "when revocation service is disabled" do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_enabled).and_return(false)
    end

    specify { expect(subject).to eql({ message: "Token revocation is disabled", status: :error }) }
  end

  context "when revocation service is enabled" do
    before do
      allow(::Gitlab::CurrentSettings).to receive(:secret_detection_token_revocation_enabled).and_return(true)
      stub_revoke_token_api_with_success
    end

    context "with a list of valid token types" do
      before do
        stub_revocation_token_types_api_with_success
      end

      specify { expect(subject[:status]).to be(:success) }

      context "when there is no token to be revoked" do
        let_it_be(:revocable_token_types) do
          { "types": %w() }
        end

        it "returns error" do
          expect(subject[:status]).to be(:error)
          expect(subject[:message]).to eql("No revocable key is present")
        end
      end
    end

    context "when revocation token types API returns an unsuccessful response" do
      before do
        stub_revocation_token_types_api_with_failure
      end

      it "returns error" do
        expect(subject[:status]).to be(:error)
        expect(subject[:message]).to eql("Failed to get revocation token types")
      end
    end
  end

  def stub_revoke_token_api_with_success
    stub_request(:post, token_revocation_url)
      .with(body: revocable_keys.to_json)
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: {}.to_json
      )
  end

  def stub_revoke_token_api_with_failure
    stub_request(:post, token_revocation_url)
      .with(body: revocable_keys.to_json)
      .to_return(
        status: 400,
        headers: { 'Content-Type' => 'application/json' },
        body: {}.to_json
      )
  end

  def stub_revocation_token_types_api_with_success
    stub_request(:get, revocation_token_types_url)
      .to_return(
        status: 200,
        headers: { 'Content-Type' => 'application/json' },
        body: revocable_token_types.to_json
      )
  end

  def stub_revocation_token_types_api_with_failure
    stub_request(:get, revocation_token_types_url)
      .to_return(
        status: 400,
        headers: { 'Content-Type' => 'application/json' },
        body: {}.to_json
      )
  end
end
