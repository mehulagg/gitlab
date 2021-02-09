# frozen_string_literal: true

module EE
  module API
    module Entities
      class IssuableMetricImage < Grape::Entity
        expose :id, :created_at
        expose :filename, :file_path, :url
      end
    end
  end
end
