# frozen_string_literal: true

module API
  class ErrorTrackingCollector < ::API::Base
    feature_category :error_tracking

    content_type :envelope, 'application/x-sentry-envelope'
    default_format :envelope

    helpers do
      def save_to_db(event_info, type_info, event)
        return unless type_info['type'] == 'event'

        exception = event['exception']['values'].first

        # Let's find or create an error based on some exception data
        error = user_project.error_tracking_errors.find_or_create_by!(
          name: exception['type'],
          description: exception['value'],
          actor: event['transaction'],
          platform: event['platform']
        )

        error.events.create!(
          environment: event['environment'],
          description: exception['type'],
          level: event['level'],
          occurred_at: event['timestamp'],
          payload: event
        )
      end

      def save_to_file(type, event_id, content)
        # Write to Rails tmp dir
        timestamp = Time.now.to_i.to_s
        file_name = [type, event_id, timestamp].join('-') + '.txt'
        File.write(Rails.root.join('tmp', file_name), content)
      end
    end

    params do
      requires :id, type: String, desc: 'The ID of a project'
    end

    resource :projects, requirements: API::NAMESPACE_OR_PROJECT_REQUIREMENTS do
      desc 'Submit error tracking event to the project' do
        detail 'This feature was introduced in GitLab 14.1.'
      end
      params do
      end
      post ':id/error_tracking/collector/*path' do
        # Request body can be "" or "gzip".
        # If later then body was compressed with Zlib.gzip
        encoding = request.headers["Content-Encoding"]

        body = if encoding == 'gzip'
                 Zlib.gunzip(request.body.read)
               else
                 request.body.read
               end

        # Request body contains 3 json objects merged together.
        # We need to separate and parse them into hash objects.
        parser = Yajl::Parser.new
        entries = []

        parser.parse(body) do |content|
          entries << content
        end

        event_info, type_info, event = entries

        type = type_info['type']

        raise 'Unsupported envelope type' unless type == 'transaction' || type == 'event'

        save_to_file(type, event_info['event_id'], body)
        save_to_db(event_info, type_info, event)

        status 204
      end
    end
  end
end
