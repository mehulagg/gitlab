# frozen_string_literal: true

module StatusPage
  module PublicationServiceResponses
    extend ActiveSupport::Concern

    def error(message, payload = {})
      ServiceResponse.error(message: message, payload: payload)
    end

    def success(payload = {})
      ServiceResponse.success(payload: payload)
    end
  end
end
