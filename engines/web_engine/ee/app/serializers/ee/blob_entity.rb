# frozen_string_literal: true

module EE
  module BlobEntity
    extend ActiveSupport::Concern

    prepended do
      expose :file_lock, if: -> (*) { request.respond_to?(:ref) }, using: FileLockEntity do |blob|
        if request.project.root_ref?(request.ref)
          request.project.find_path_lock(blob.path, exact_match: true)
        end
      end
    end
  end
end
