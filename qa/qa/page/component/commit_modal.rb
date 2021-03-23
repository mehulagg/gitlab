# frozen_string_literal: true

module QA
  module Page
    module Component
      module CommitModal
        extend QA::Page::PageConcern

        def self.included(base)
          super

          base.view 'app/assets/javascripts/projects/commit/components/form_modal.vu' do
            element :submit_commit_button, required: true
          end
        end
      end
    end
  end
end
