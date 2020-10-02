# frozen_string_literal: true

module QA
  module Page
    module Dashboard
      module Snippet
        class Index < Page::Base
          include Page::Component::SnippetIndex
        end
      end
    end
  end
end

QA::Page::Dashboard::Snippet::Index.prepend_if_ee('QA::EE::Page::Dashboard::Snippet::Index')
