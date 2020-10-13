# frozen_string_literal: true

module Gitlab
  module StatusPage
    module Storage
      module WrapsStorageErrors
        def wrap_errors(**args)
          yield
        rescue Aws::Errors::ServiceError => e
          raise Error.new(bucket: bucket_name, error: e, **args)
        end
      end
    end
  end
end
