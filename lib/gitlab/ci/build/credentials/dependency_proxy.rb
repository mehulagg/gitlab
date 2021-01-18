# frozen_string_literal: true

module Gitlab
  module Ci
    module Build
      module Credentials
        class DependencyProxy < Base
          attr_reader :username, :password

          def initialize(build)
            @username = ::Gitlab::Auth::CI_JOB_USER
            @password = build.token
          end

          def url
            "#{Gitlab.config.gitlab.host}:#{Gitlab.config.gitlab.port}"
          end

          def valid?
            Gitlab.config.dependency_proxy.enabled
          end
        end
      end
    end
  end
end
