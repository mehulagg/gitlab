# frozen_string_literal: true

module Gitlab
  module APIAuthentication
    class TokenLocator
      UsernameAndPassword = Struct.new(:username, :password)

      include ActiveModel::Validations
      include ActionController::HttpAuthentication::Basic

      attr_reader :location

      validates :location, inclusion: { in: %i[http_basic_auth token_auth] }

      def initialize(location)
        @location = location
        validate!
      end

      def extract(request)
        case @location
        when :http_basic_auth
          extract_from_http_basic_auth request
        when :token_auth
          extract_from_token_auth request
        end
      end

      private

      def extract_from_http_basic_auth(request)
        username, password = user_name_and_password(request)
        return unless username.present? && password.present?

        UsernameAndPassword.new(username, password)
      end

      def extract_from_token_auth(request)
        password = request.headers['Authorization']
        return unless password.present?

        UsernameAndPassword.new(nil, password)
      end
    end
  end
end
