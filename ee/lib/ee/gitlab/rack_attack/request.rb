# frozen_string_literal: true

module EE
  module Gitlab
    module RackAttack
      module Request
        extend ::Gitlab::Utils::Override

        override :should_be_skipped?
        def should_be_skipped?
          super || geo?
        end

        def geo?
          ::Gitlab::Geo::JwtRequestDecoder.geo_auth_attempt?(env['HTTP_AUTHORIZATION']) if env['HTTP_AUTHORIZATION']
        end
      end
    end
  end
end
