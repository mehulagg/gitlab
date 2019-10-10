require 'net/http'
require 'json'
require 'uri'

module Gitlab
  module QA
    module Component
      class Staging
        ADDRESS = 'https://staging.gitlab.com'.freeze

        def self.release
          Release.new(image)
        rescue Support::InvalidResponseError => ex
          warn ex.message
          warn "#{ex.response.code} #{ex.response.message}: #{ex.response.body}"
          exit 1
        end

        def self.image
          if Runtime::Env.dev_access_token_variable
            # Auto-deploy builds have a tag formatted like 12.1.12345+5159f2949cb.59c9fa631
            # where `5159f2949cb` is the EE commit SHA. QA images are tagged using
            # the version from the VERSION file and this commit SHA, e.g.
            # `12.0-5159f2949cb` (note that the `major.minor` doesn't necessarily match).
            # To work around that, we're fetching the `revision` from the version API
            # and then find the corresponding QA image in the
            # `dev.gitlab.org:5005/gitlab/omnibus-gitlab/gitlab-ee-qa` container
            # registry, based on this revision.
            # See:
            #  - https://gitlab.com/gitlab-org/quality/staging/issues/56
            #  - https://gitlab.com/gitlab-org/release/framework/issues/421
            #  - https://gitlab.com/gitlab-org/gitlab-qa/issues/398
            Support::DevEEQAImage.new.retrieve_image_from_container_registry!(staging_revision)
          else
            # Auto-deploy builds have a tag formatted like 12.0.12345+5159f2949cb.59c9fa631
            # but the version api returns a semver version like 12.0.1
            # so images are tagged using minor and major semver components plus
            # the EE commit ref, which is the 'revision' returned by the API
            # and so the version used for the docker image tag is like 12.0-5159f2949cb
            # See: https://gitlab.com/gitlab-org/quality/staging/issues/56
            "ee:#{Version.new(address).major_minor_revision}"
          end
        end

        def self.address
          self::ADDRESS
        end

        def self.staging_revision
          @staging_revision ||= Version.new(address).revision
        end

        class Version
          attr_reader :uri

          def initialize(address)
            @uri = URI.join(address, '/api/v4/version')

            Runtime::Env.require_qa_access_token!
          end

          def revision
            api_get!.fetch('revision')
          end

          def major_minor_revision
            api_response = api_get!
            version_regexp = /^v?(?<major>\d+)\.(?<minor>\d+)\.\d+/
            match = version_regexp.match(api_response.fetch('version'))

            "#{match[:major]}.#{match[:minor]}-#{api_response.fetch('revision')}"
          end

          private

          def api_get!
            @response_body ||= # rubocop:disable Naming/MemoizedInstanceVariableName
              begin
                response = Support::GetRequest.new(uri, Runtime::Env.qa_access_token).execute!
                JSON.parse(response.body)
              end
          end
        end
      end
    end
  end
end
