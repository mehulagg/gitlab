# frozen_string_literal: true

require_dependency 'gitlab/email/handler'

# Inspired in great part by Discourse's Email::Receiver
module Gitlab
  module Email
    class Receiver
      include Gitlab::Utils::StrongMemoize

      def initialize(raw)
        @raw = raw
      end

      def execute
        raise EmptyEmailError if @raw.blank?

        ignore_auto_reply!

        raise UnknownIncomingEmail unless handler

        handler.execute.tap do
          Gitlab::Metrics::BackgroundTransaction.current&.add_event(handler.metrics_event, handler.metrics_params)
        end
      end

      def mail_metadata
        {
          mail_uid: mail.message_id,
          from_address: mail.from,
          to_address: mail.to,
          mail_key: mail_key,
          references: Array(mail.references),
          delivered_to: delivered_to.map(&:value),
          envelope_to: envelope_to.map(&:value),
          x_envelope_to: x_envelope_to.map(&:value)
        }
      end

      private

      def handler
        strong_memoize(:handler) { find_handler }
      end

      def find_handler
        Handler.for(mail, mail_key)
      end

      def mail
        strong_memoize(:mail) { build_mail }
      end

      def build_mail
        Mail::Message.new(@raw)
      rescue Encoding::UndefinedConversionError,
             Encoding::InvalidByteSequenceError => e
        raise EmailUnparsableError, e
      end

      def mail_key
        strong_memoize(:mail_key) do
          key_from_to_header || key_from_additional_headers
        end
      end

      def key_from_to_header
        mail.to.find do |address|
          key = Gitlab::IncomingEmail.key_from_address(address)
          break key if key
        end
      end

      def key_from_additional_headers
        find_key_from_references ||
          find_key_from_delivered_to_header ||
          find_key_from_envelope_to_header ||
          find_key_from_x_envelope_to_header
      end

      def ensure_references_array(references)
        case references
        when Array
          references
        when String
          # Handle emails from clients which append with commas,
          # example clients are Microsoft exchange and iOS app
          Gitlab::IncomingEmail.scan_fallback_references(references)
        when nil
          []
        end
      end

      def find_key_from_references
        ensure_references_array(mail.references).find do |mail_id|
          key = Gitlab::IncomingEmail.key_from_fallback_message_id(mail_id)
          break key if key
        end
      end

      def delivered_to
        Array(mail[:delivered_to])
      end

      def envelope_to
        Array(mail[:envelope_to])
      end

      def x_envelope_to
        Array(mail[:x_envelope_to])
      end

      def find_key_from_delivered_to_header
        delivered_to.find do |header|
          key = Gitlab::IncomingEmail.key_from_address(header.value)
          break key if key
        end
      end

      def find_key_from_envelope_to_header
        envelope_to.find do |header|
          key = Gitlab::IncomingEmail.key_from_address(header.value)
          break key if key
        end
      end

      def find_key_from_x_envelope_to_header
        x_envelope_to.find do |header|
          key = Gitlab::IncomingEmail.key_from_address(header.value)
          break key if key
        end
      end

      def ignore_auto_reply!
        if auto_submitted? || auto_replied?
          raise AutoGeneratedEmailError
        end
      end

      def auto_submitted?
        # Mail::Header#[] is case-insensitive
        auto_submitted = mail.header['Auto-Submitted']&.value

        # Mail::Field#value would strip leading and trailing whitespace
        # See also https://tools.ietf.org/html/rfc3834
        auto_submitted && auto_submitted != 'no'
      end

      def auto_replied?
        autoreply = mail.header['X-Autoreply']&.value

        autoreply && autoreply == 'yes'
      end
    end
  end
end
