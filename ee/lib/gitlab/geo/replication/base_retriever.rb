# frozen_string_literal: true

module Gitlab
  module Geo
    module Replication
      class BaseRetriever
        include LogHelpers
        include Gitlab::Utils::StrongMemoize

        attr_reader :object_db_id, :extra_params

        def initialize(object_db_id, extra_params)
          @object_db_id = object_db_id
          @extra_params = extra_params
        end

        private

        def success(file)
          { code: :ok, message: 'Success', file: file }
        end

        def error(message)
          { code: :not_found, message: message }
        end

        # A 404 implies the client made a mistake requesting that resource.
        # In this case, we know that the resource should exist, so it is a 500 server error.
        # We send a special "geo_code" so the secondary can mark the file as synced.
        def file_not_found(resource)
          {
            code: :not_found,
            geo_code: Replication::FILE_NOT_FOUND_GEO_CODE,
            message: "#{resource.class.name} ##{resource.id} file not found"
          }
        end
      end
    end
  end
end
