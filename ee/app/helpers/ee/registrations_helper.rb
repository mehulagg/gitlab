# frozen_string_literal: true

module EE
  module RegistrationsHelper
    include ::Gitlab::Utils::StrongMemoize

    private

    def redirect_path
      strong_memoize(:redirect_path) do
        redirect_to = session['user_return_to']
        URI.parse(redirect_to).path if redirect_to
      end
    end
  end
end
