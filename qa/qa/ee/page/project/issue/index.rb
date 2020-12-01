# frozen_string_literal: true

module QA
  module EE
    module Page
      module Project
        module Issue
          module Index
            extend QA::Page::PageConcern

            def self.prepended(base)
              super

              base.class_eval do
                view 'app/views/shared/issuable/_search_bar.html.haml' do
                  element :issue_filter_form, /form_tag.+class: 'filter-form / # rubocop:disable QA/ElementWithPattern
                  element :issue_filter_input, /%input.form-control.filtered-search/ # rubocop:disable QA/ElementWithPattern
                end

                view 'app/assets/javascripts/issues_list/components/issuable.vue' do
                  element :issuable_weight_content
                end
              end
            end

            def issuable_weight
              find_element(:issuable_weight_content)
            end

            def wait_for_issue_replication(issue)
              wait_until do
                filter_by_title(issue.title)

                page.has_content?(issue.title)
              end

              click_issue_link(issue.title)
            end

            def filter_by_title(title)
              page.within('form.filter-form') do
                fill_in class: 'filtered-search', with: title
              end
            end
          end
        end
      end
    end
  end
end
