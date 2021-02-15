
# frozen_string_literal: true

module QA
  module Page
    module Project
      module Registry
        class Show < QA::Page::Base
          def has_image_repository?(name)
            find('a[data-testid="details-link"]', text: name)
          end
        end
      end
    end
  end
end
