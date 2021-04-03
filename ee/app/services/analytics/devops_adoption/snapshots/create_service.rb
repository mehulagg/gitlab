# frozen_string_literal: true

module Analytics
  module DevopsAdoption
    module Snapshots
      class CreateService < UpdateService
        def initialize(**args)
          super(**{ snapshot: Snapshot.new }.merge(args))
        end
      end
    end
  end
end
