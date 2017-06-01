module Ci
  module API
    # Builds API
    class Builds < Grape::API
      resource :builds do
        # Runs oldest pending build by runner - Runners only
        #
        # Parameters:
        #   token (required) - The uniq token of runner
        #
        # Example Request:
        #   POST /builds/register
        post "register" do
          authenticate_runner!
          required_attributes! [:token]
          not_found! unless current_runner.active?
          update_runner_info

          if current_runner.is_runner_queue_value_latest?(params[:last_update])
            header 'X-GitLab-Last-Update', params[:last_update]
            Gitlab::Metrics.add_event(:build_not_found_cached)
            return build_not_found!
          end

          new_update = current_runner.ensure_runner_queue_value

          result = Ci::RegisterJobService.new(current_runner).execute

          if result.valid?
            if result.build
              Gitlab::Metrics.add_event(:build_found,
                                        project: result.build.project.path_with_namespace)

              present result.build, with: Entities::BuildDetails
            else
              Gitlab::Metrics.add_event(:build_not_found)

              header 'X-GitLab-Last-Update', new_update

              build_not_found!
            end
          else
            # We received build that is invalid due to concurrency conflict
            Gitlab::Metrics.add_event(:build_invalid)
            conflict!
          end
        end

        # Update an existing build - Runners only
        #
        # Parameters:
        #   id (required) - The ID of a project
        #   state (optional) - The state of a build
        #   trace (optional) - The trace of a build
        # Example Request:
        #   PUT /builds/:id
        put ":id" do
          authenticate_runner!
          build = Ci::Build.where(runner_id: current_runner.id).running.find(params[:id])
          validate_build!(build)

          update_runner_info

          build.trace.set(params[:trace]) if params[:trace]

          Gitlab::Metrics.add_event(:update_build,
                                    project: build.project.path_with_namespace)

          case params[:state].to_s
          when 'success'
            build.success
          when 'failed'
            build.drop
          end
        end

        # Send incremental log update - Runners only
        #
        # Parameters:
        #   id (required) - The ID of a build
        # Body:
        #   content of logs to append
        # Headers:
        #   Content-Range (required) - range of content that was sent
        #   BUILD-TOKEN (required) - The build authorization token
        # Example Request:
        #   PATCH /builds/:id/trace.txt
        patch ":id/trace.txt" do
          build = authenticate_build!

          error!('400 Missing header Content-Range', 400) unless request.headers.has_key?('Content-Range')
          content_range = request.headers['Content-Range']
          content_range = content_range.split('-')

          stream_size = build.trace.append(request.body.read, content_range[0].to_i)
          if stream_size < 0
            return error!('416 Range Not Satisfiable', 416, { 'Range' => "0-#{-stream_size}" })
          end

          status 202
          header 'Build-Status', build.status
          header 'Range', "0-#{stream_size}"
        end

        # Authorize artifacts uploading for build - Runners only
        #
        # Parameters:
        #   id (required) - The ID of a build
        #   token (required) - The build authorization token
        #   filesize (optional) - the size of uploaded file
        # Example Request:
        #   POST /builds/:id/artifacts/authorize
        post ":id/artifacts/authorize" do
          require_gitlab_workhorse!
          Gitlab::Workhorse.verify_api_request!(headers)
          not_allowed! unless Gitlab.config.artifacts.enabled
          build = authenticate_build!
          forbidden!('build is not running') unless build.running?

          if params[:filesize]
            file_size = params[:filesize].to_i
            file_to_large! unless file_size < max_artifacts_size
          end

          status 200
          content_type Gitlab::Workhorse::INTERNAL_API_CONTENT_TYPE
          Gitlab::Workhorse.artifact_upload_ok
        end

        # Upload artifacts to build - Runners only
        #
        # Parameters:
        #   id (required) - The ID of a build
        #   token (required) - The build authorization token
        #   file (required) - Artifacts file
        #   expire_in (optional) - Specify when artifacts should expire (ex. 7d)
        # Parameters (accelerated by GitLab Workhorse):
        #   file.path - path to locally stored body (generated by Workhorse)
        #   file.name - real filename as send in Content-Disposition
        #   file.type - real content type as send in Content-Type
        #   metadata.path - path to locally stored body (generated by Workhorse)
        #   metadata.name - filename (generated by Workhorse)
        # Headers:
        #   BUILD-TOKEN (required) - The build authorization token, the same as token
        # Body:
        #   The file content
        #
        # Example Request:
        #   POST /builds/:id/artifacts
        post ":id/artifacts" do
          require_gitlab_workhorse!
          not_allowed! unless Gitlab.config.artifacts.enabled
          build = authenticate_build!
          forbidden!('Build is not running!') unless build.running?

          artifacts_upload_path = ArtifactUploader.artifacts_upload_path
          artifacts = uploaded_file(:file, artifacts_upload_path)
          metadata = uploaded_file(:metadata, artifacts_upload_path)

          bad_request!('Missing artifacts file!') unless artifacts
          file_to_large! unless artifacts.size < max_artifacts_size

          build.artifacts_file = artifacts
          build.artifacts_metadata = metadata
          build.artifacts_expire_in =
            params['expire_in'] ||
            Gitlab::CurrentSettings.current_application_settings
              .default_artifacts_expire_in

          if build.save
            present(build, with: Entities::BuildDetails)
          else
            render_validation_error!(build)
          end
        end

        # Download the artifacts file from build - Runners only
        #
        # Parameters:
        #   id (required) - The ID of a build
        #   token (required) - The build authorization token
        # Headers:
        #   BUILD-TOKEN (required) - The build authorization token, the same as token
        # Example Request:
        #   GET /builds/:id/artifacts
        get ":id/artifacts" do
          build = authenticate_build!
          artifacts_file = build.artifacts_file

          unless artifacts_file.exists?
            not_found!
          end

          unless artifacts_file.file_storage?
            return redirect_to build.artifacts_file.url
          end

          present_file!(artifacts_file.path, artifacts_file.filename)
        end

        # Remove the artifacts file from build - Runners only
        #
        # Parameters:
        #   id (required) - The ID of a build
        #   token (required) - The build authorization token
        # Headers:
        #   BUILD-TOKEN (required) - The build authorization token, the same as token
        # Example Request:
        #   DELETE /builds/:id/artifacts
        delete ":id/artifacts" do
          build = authenticate_build!

          status(200)
          build.erase_artifacts!
        end
      end
    end
  end
end
