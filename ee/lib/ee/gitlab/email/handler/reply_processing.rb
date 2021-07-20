# frozen_string_literal: true

module EE
  module Gitlab
    module Email
      module Handler
        module ReplyProcessing
          extend ::Gitlab::Utils::Override

          private

          override :upload_params
          def upload_params
            return super unless try(:noteable).is_a?(Epic)

            {
              upload_parent: noteable.group,
              uploader_class: NamespaceFileUploader
            }
          end
        end
      end
    end
  end
end
