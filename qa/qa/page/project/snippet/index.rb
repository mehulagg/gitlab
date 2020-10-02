# frozen_string_literal: true

module QA
  module Page
    module Project
      module Snippet
        class Index < Page::Base
          include Page::Component::SnippetIndex
        end
      end
    end
  end
end

QA::Page::Project::Snippet::Index.prepend_if_ee('QA::EE::Page::Project::Snippet::Index')
