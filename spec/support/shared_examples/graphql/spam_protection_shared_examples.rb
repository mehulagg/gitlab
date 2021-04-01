# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'has spam protection' do
  include AfterNextHelpers

  describe '#check_spam_action_response!' do
    let(:variables) { nil }
    let(:headers) { {} }
    let(:spam_log_id) { 123 }
    let(:captcha_site_key) { 'asdfgh' }

    def send_request
      post_graphql_mutation(mutation, current_user: current_user)
    end

    before do
      expect_next(mutation_class).to receive(:spam_action_response_fields).and_return(
        spam: spam,
        needs_captcha_response: render_captcha,
        spam_log_id: spam_log_id,
        captcha_site_key: captcha_site_key
      )
    end

    context 'when the object is not spam and no CAPTCHA is required' do
      let(:spam) { false }
      let(:render_captcha) { false }

      it 'does not return a top-level error' do
        send_request

        expect(graphql_errors).to be_blank
      end
    end

    context 'when the object is spam and no CAPTCHA is available' do
      let(:spam) { true }
      let(:render_captcha) { false }

      it 'informs the client that the request was denied as spam' do
        send_request

        expect(graphql_errors).to contain_exactly a_hash_including(
          'message' => ::Mutations::SpamProtection::SPAM_DISALLOWED_MESSAGE
        )
      end
    end

    context 'when the object is spam and a CAPTCHA is required' do
      let(:spam) { true }
      let(:render_captcha) { true }

      it 'informs the client that the request was denied as spam' do
        send_request

        expect(graphql_errors).to contain_exactly a_hash_including(
          'message' => ::Mutations::SpamProtection::SPAM_DISALLOWED_MESSAGE
        )
      end
    end

    context 'when the object is not spam and a CAPTCHA is required' do
      let(:spam) { false }
      let(:render_captcha) { true }

      it 'informs the client that the request may be retried after solving the CAPTCHA' do
        send_request

        expect(graphql_errors).to contain_exactly a_hash_including(
          'message' => ::Mutations::SpamProtection::NEEDS_CAPTCHA_RESPONSE_MESSAGE
        )
      end
    end
  end
end
