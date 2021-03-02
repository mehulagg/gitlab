# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module Wiki
          class Edit < QA::Page::Base
            include QA::Page::Component::WikiPageForm
            include QA::Page::Component::WikiSidebar
          end
        end
      end
    end
  end
end
