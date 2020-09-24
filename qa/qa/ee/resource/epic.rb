# frozen_string_literal: true

module QA
  module EE
    module Resource
      class Epic < QA::Resource::Base
        attr_accessor :title

        attribute :group do
          QA::Resource::Group.fabricate!
        end

        attribute :id
        attribute :iid
        attribute :start_date_is_fixed
        attribute :start_date_fixed
        attribute :due_date_is_fixed
        attribute :due_date_fixed
        attribute :confidential

        def initialize
          @start_date_is_fixed = false
          @start_date_fixed = nil
          @due_date_is_fixed = false
          @due_date_fixed = nil
          @confidential = false
        end

        def fabricate!
          group.visit!

          QA::Page::Group::Menu.perform(&:click_group_epics_link)

          QA::EE::Page::Group::Epic::Index.perform do |index|
            index.click_new_epic
            index.set_title(@title)
            index.enable_confidential_epic if @confidential
            index.create_new_epic
            index.has_text?(@title, wait: QA::Support::Repeater::DEFAULT_MAX_WAIT_TIME)
          end
        end

        def api_get_path
          "/groups/#{group.id}/epics/#{id}"
        end

        def api_post_path
          "/groups/#{group.id}/epics"
        end

        def api_post_body
          {
            title: title,
            start_date_is_fixed: @start_date_is_fixed,
            start_date_fixed: @start_date_fixed,
            due_date_is_fixed: @due_date_is_fixed,
            due_date_fixed: @due_date_fixed,
            confidential: @confidential
          }
        end
      end
    end
  end
end
