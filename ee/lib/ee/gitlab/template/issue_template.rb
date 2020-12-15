# frozen_string_literal: true

module EE
  module Gitlab
    module Template
      module IssueTemplate
        extend ActiveSupport::Concern

        class_methods do
          extend ::Gitlab::Utils::Override

          override :categories
          def by_category(category, project = nil, empty_category: nil)
            super(category, project, empty_category: _('Project Templates'))
          end
        end
      end
    end
  end
end
