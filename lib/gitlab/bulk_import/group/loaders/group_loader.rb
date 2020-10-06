# frozen_string_literal: true

module Gitlab
  module BulkImport
    module Group
      module Loaders
        class GroupLoader
          def self.load(context, data)
            Groups::CreateService.new(context.current_user, data).execute
          end
        end
      end
    end
  end
end
