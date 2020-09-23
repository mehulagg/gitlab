# frozen_string_literal: true

module Gitlab
  module Auth
    module GroupSaml
      class XmlResponse
        attr_reader :saml_response

        def initialize(group:, raw_response:)
          settings = Gitlab::Auth::GroupSaml::DynamicSettings.new(group).to_h
          @saml_response = OneLogin::RubySaml::Response.new(raw_response, settings: OneLogin::RubySaml::Settings.new(settings))
        end

        def errors
          validate_all

          saml_response.errors.to_set + (saml_response.decrypted_document&.errors || []) + (saml_response.document&.errors || [])
        end

        def valid?
          validate_all
        end

        def name_id
          saml_response.nameid
        end

        def name_id_format
          saml_response.name_id_format
        end

        def xml
          saml_response.response
        end

        private

        def validate_all
          # Pass true to detect multiple errors instead of
          # raising an error on the first one
          saml_response.is_valid?(true)
        end
      end
    end
  end
end
