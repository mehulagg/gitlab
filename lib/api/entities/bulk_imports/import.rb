# frozen_string_literal: true

module API
  module Entities
    module BulkImports
      class Import < Grape::Entity
        expose :id
        expose :status_name, as: :status
        expose :source_type
        expose :created_at
        expose :updated_at
      end
    end
  end
end
