# frozen_string_literal: true

module Gitlab
  module GithubImport
    # ObjectImporter defines the base behaviour for every Sidekiq worker that
    # imports a single resource such as a note or pull request.
    module ObjectImporter
      extend ActiveSupport::Concern

      PROJECT_IMPORT_COUNTER_KEY = 'github-importer/project/%{project}/counter/%{counter_name}'

      included do
        include ApplicationWorker

        sidekiq_options retry: 3
        include GithubImport::Queue
        include ReschedulingMethods
        include Gitlab::NotifyUponDeath

        feature_category :importers
        worker_has_external_dependencies!

        def logger
          @logger ||= Gitlab::Import::Logger.build
        end
      end

      # project - An instance of `Project` to import the data into.
      # client - An instance of `Gitlab::GithubImport::Client`
      # hash - A Hash containing the details of the object to import.
      def import(project, client, hash)
        object = representation_class.from_json_hash(hash)

        # To better express in the logs what object is being imported.
        self.github_id = object.attributes.fetch(:github_id)

        info(project.id, message: 'starting importer')

        importer_class.new(object, project, client).execute

        increment_counters(project)

        info(project.id, message: 'importer finished')
      rescue StandardError => e
        error(project.id, e, hash)
      end

      # Counters incremented:
      # - global (prometheus): for metrics in Grafana
      # - project (redis): used in FinishImportWorker to report number of objects imported
      def increment_counters(project)
        counter.increment
        Gitlab::GithubImport.increment_object_count(project, project_counter_key(project))
      end

      def project_counter_key(project)
        PROJECT_IMPORT_COUNTER_KEY % { project: project.id, counter_name: counter_name }
      end

      def counter
        @counter ||= Gitlab::Metrics.counter(counter_name, counter_description)
      end

      # Returns the representation class to use for the object. This class must
      # define the class method `from_json_hash`.
      def representation_class
        raise NotImplementedError
      end

      # Returns the class to use for importing the object.
      def importer_class
        raise NotImplementedError
      end

      # Returns the name (as a Symbol) of the Prometheus counter.
      def counter_name
        raise NotImplementedError
      end

      # Returns the description (as a String) of the Prometheus counter.
      def counter_description
        raise NotImplementedError
      end

      private

      attr_accessor :github_id

      def info(project_id, extra = {})
        logger.info(log_attributes(project_id, extra))
      end

      def error(project_id, exception, data = {})
        logger.error(
          log_attributes(
            project_id,
            message: 'importer failed',
            'error.message': exception.message,
            'github.data': data
          )
        )

        Gitlab::ErrorTracking.track_and_raise_exception(
          exception,
          log_attributes(project_id)
        )
      end

      def log_attributes(project_id, extra = {})
        extra.merge(
          import_source: :github,
          project_id: project_id,
          importer: importer_class.name,
          github_id: github_id
        )
      end
    end
  end
end
