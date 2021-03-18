# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Validate
          class External < Chain::Base
            include Chain::Helpers

            InvalidResponseCode = Class.new(StandardError)

            VALIDATION_REQUEST_TIMEOUT = 5

            def perform!
              pipeline_authorized = validate_external

              log_message = pipeline_authorized ? 'authorized' : 'not authorized'
              Gitlab::AppLogger.info(message: "Pipeline #{log_message}", project_id: @pipeline.project.id, user_id: @pipeline.user.id)

              error('External validation failed', drop_reason: :external_validation_failure) unless pipeline_authorized
            end

            def break?
              @pipeline.errors.any?
            end

            private

            def validate_external
              return true unless validation_service_url

              # 200 - accepted
              # 4xx - not accepted
              # everything else - accepted and logged
              response_code = validate_service_request.code
              case response_code
              when 200
                true
              when 400..499
                false
              else
                raise InvalidResponseCode, "Unsupported response code received from Validation Service: #{response_code}"
              end
            rescue => ex
              Gitlab::ErrorTracking.track_exception(ex)

              true
            end

            def validate_service_request
              Gitlab::HTTP.post(
                validation_service_url, timeout: VALIDATION_REQUEST_TIMEOUT,
                body: validation_service_payload(@pipeline, @command.yaml_processor_result.stages_attributes).to_json
              )
            end

            def validation_service_url
              ENV['EXTERNAL_VALIDATION_SERVICE_URL']
            end

            def validation_service_payload(pipeline, stages_attributes)
              {
                project: {
                  id: pipeline.project.id,
                  path: pipeline.project.full_path,
                  created_at: pipeline.project.created_at&.iso8601
                },
                user: {
                  id: pipeline.user.id,
                  username: pipeline.user.username,
                  email: pipeline.user.email,
                  created_at: pipeline.user.created_at&.iso8601
                },
                pipeline: {
                  sha: pipeline.sha,
                  ref: pipeline.ref,
                  type: pipeline.source
                },
                builds: builds_validation_payload(stages_attributes)
              }
            end

            def builds_validation_payload(stages_attributes)
              stages_attributes.map { |stage| stage[:builds] }.flatten
                .map(&method(:build_validation_payload))
            end

            def build_validation_payload(build)
              {
                name: build[:name],
                stage: build[:stage],
                image: build.dig(:options, :image, :name),
                services: build.dig(:options, :services)&.map { |service| service[:name] },
                script: [
                  build.dig(:options, :before_script),
                  build.dig(:options, :script),
                  build.dig(:options, :after_script)
                ].flatten.compact
              }
            end
          end
        end
      end
    end
  end
end

Gitlab::Ci::Pipeline::Chain::Validate::External.prepend_if_ee('EE::Gitlab::Ci::Pipeline::Chain::Validate::External')
