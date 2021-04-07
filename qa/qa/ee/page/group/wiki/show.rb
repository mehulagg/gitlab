# frozen_string_literal: true

module QA
  module EE
    module Page
      module Group
        module Wiki
          class Show < QA::Page::Base
            include QA::Page::Component::Wiki
            include QA::Page::Component::WikiSidebar
            include QA::Page::Component::LazyLoader
            include QA::Page::Component::LegacyClonePanel
          end
        end
      end
    end
  end
end
