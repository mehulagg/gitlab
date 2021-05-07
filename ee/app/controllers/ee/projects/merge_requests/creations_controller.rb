# frozen_string_literal: true

module EE
  module Projects
    module MergeRequests
      module CreationsController
        extend ActiveSupport::Concern

        prepended do
          before_action :disable_query_limiting, only: [:create]
        end

        private

        def disable_query_limiting
          ::Gitlab::QueryLimiting.disable!('https://gitlab.com/gitlab-org/gitlab/-/issues/20801')
        end
      end
    end
  end
end
