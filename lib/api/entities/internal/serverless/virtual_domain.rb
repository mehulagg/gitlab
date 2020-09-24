# frozen_string_literal: true

module API
  module Entities
    module Internal
      module Serverless
        class VirtualDomain < Grape::Entity
          expose :certificate, :key
          expose :lookup_paths, using: LookupPath
        end
      end
    end
  end
end
