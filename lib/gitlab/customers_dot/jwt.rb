# frozen_string_literal: true

module Gitlab
  module CustomersDot
    class Jwt


      private

      def key
        key_data = Gitlab::CurrentSettings.customers_dot_signing_key
      end
    end
  end
end

