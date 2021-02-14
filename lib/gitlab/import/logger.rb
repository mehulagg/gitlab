# frozen_string_literal: true

module Gitlab
  module Import
    class Logger < ::Gitlab::JsonLogger
      attr_accessor :import_type

      IMPORTERS = %i[
        github_import
        bitbucket_cloud_import
        bitbucket_server_import
        jira_import
        bulkimports_gitlab
      ]

      def self.file_name_noext
        'importer'
      end

      def self.build(import_type = nil)
        Gitlab::SafeRequestStore[self.cache_key] ||=
          super().tap do |logger|
            logger.import_type = import_type if IMPORTERS.include?(import_type.to_sym)
          end
      end

      def format_message(severity, timestamp, progname, message)
        data = { import_type: importer }

        case message
        when String
          data[:message] = message
        when Hash
          data.merge!(message)
        end

        super(severity, timestamp, progname, data)
      end
    end
  end
end
