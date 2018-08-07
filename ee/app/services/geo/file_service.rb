module Geo
  class FileService
    include ExclusiveLeaseGuard
    include ::Gitlab::Geo::LogHelpers

    attr_reader :object_type, :object_db_id

    DEFAULT_OBJECT_TYPES = %w[attachment avatar file import_export namespace_file personal_file].freeze
    DEFAULT_SERVICE_TYPE = 'file'.freeze

    def initialize(object_type, object_db_id)
      @object_type = object_type.to_sym
      @object_db_id = object_db_id
    end

    def execute
      raise NotImplementedError
    end

    private

    def service_klass_name
      klass_name =
        if DEFAULT_OBJECT_TYPES.include?(object_type.to_s)
          DEFAULT_SERVICE_TYPE
        else
          object_type
        end

      klass_name.to_s.camelize
    end

    def base_log_data(message)
      {
        class: self.class.name,
        object_type: object_type.to_s,
        object_db_id: object_db_id,
        message: message
      }
    end
  end
end
