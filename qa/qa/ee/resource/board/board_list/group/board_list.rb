# frozen_string_literal: true

module QA
  module EE
    module Resource
      module Board
        module BoardList
          module Group
            class BoardList < QA::Resource::Base
              attribute :id
              attribute :label_title

              attribute :group do
                QA::Resource::Group.fabricate_via_api!
              end

              attribute :board do
                QA::EE::Resource::Board::GroupBoard.fabricate_via_api! do |group_board|
                  group_board.group = group
                  group_board.name = 'Upstream'
                end
              end

              attribute :label do
                QA::Resource::GroupLabel.fabricate_via_api! do |group_label|
                  group_label.group = board.group
                  group_label.title = label_title
                end
              end

              def resource_web_url(resource)
                super
              rescue ResourceURLMissingError
                # this particular resource does not expose a web_url property
              end

              def api_get_path
                "/groups/#{board.group.id}/boards/#{board.id}/lists/#{id}"
              end

              def api_post_path
                "/groups/#{board.group.id}/boards/#{board.id}/lists"
              end

              def api_post_body
                {
                  board_id: board.id,
                  label_id: label.id
                }
              end
            end
          end
        end
      end
    end
  end
end
