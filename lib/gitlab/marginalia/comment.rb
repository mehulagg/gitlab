# frozen_string_literal: true

# Module to support correlation_id and additional job details.
module Gitlab
  module Marginalia
    module Comment
      def update_route!(route)
        self.marginalia_route = route
      end

      private

      def jid
        bg_job["jid"] if bg_job.present?
      end

      def job_class
        bg_job["class"] if bg_job.present?
      end

      def correlation_id
        if bg_job.present?
          bg_job["correlation_id"]
        else
          Labkit::Correlation::CorrelationId.current_id
        end
      end

      def bg_job
        job = ::Marginalia::Comment.marginalia_job

        # We are using 'Marginalia::SidekiqInstrumentation' which does not support 'ActiveJob::Base'.
        # Gitlab also uses 'ActionMailer::MailDeliveryJob' which inherits from ActiveJob::Base.
        # So below condition is used to return metadata for such jobs.
        if job.is_a?(ActionMailer::MailDeliveryJob)
          {
            "class" => job.arguments.first,
            "jid"   => job.job_id
          }
        else
          job
        end
      end

      def route
        marginalia_route
      end

      def marginalia_route
        Thread.current[:marginalia_route]
      end

      def marginalia_route=(route)
        Thread.current[:marginalia_route] = route
      end
    end
  end
end
