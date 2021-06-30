# frozen_string_literal: true

module Members
  module Mailgun
    class PermanentFailuresController < ApplicationController
      respond_to :json

      skip_before_action :authenticate_user!
      skip_before_action :verify_authenticity_token

      before_action :ensure_feature_enabled!
      before_action :authenticate_signature!
      before_action :validate_invite_email!

      feature_category :authentication_and_authorization

      def create
        webhook_processor.execute

        head :ok
      end

      private

      def ensure_feature_enabled!
        render_406 unless Gitlab::CurrentSettings.mailgun_events_enabled?
      end

      def authenticate_signature!
        access_denied! unless valid_signature?
      end

      def valid_signature?
        # per this guide: https://documentation.mailgun.com/en/latest/user_manual.html#webhooks
        digest = OpenSSL::Digest.new('SHA256')
        data = [params.dig(:signature, :timestamp), params.dig(:signature, :token)].join

        params.dig(:signature, :signature) == OpenSSL::HMAC.hexdigest(digest, Gitlab::CurrentSettings.mailgun_signing_key, data)
      end

      def validate_invite_email!
        # permanent_failures webhook does not provide a way to filter failures, so we'll get them all on this endpoint
        # and we only care about our invite_emails
        render_406 unless payload[:tags]&.include?('invite_email')
      end

      def webhook_processor
        ::Members::Mailgun::ProcessWebhookService.new(payload)
      end

      def payload
        @payload ||= params.permit!['event-data']
      end

      def render_406
        # failure to stop retries per https://documentation.mailgun.com/en/latest/user_manual.html#webhooks
        head :not_acceptable
      end
    end
  end
end
