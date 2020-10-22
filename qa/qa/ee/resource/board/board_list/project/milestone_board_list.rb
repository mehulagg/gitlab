# frozen_string_literal: true

module QA
  module EE
    module Resource
      module Board
        module BoardList
          module Project
            class MilestoneBoardList < BaseBoardList
              attribute :project_milestone do
                QA::Resource::ProjectMilestone.fabricate_via_api! do |project_milestone|
                  project_milestone.project = board.project
                  project_milestone.title = '1.0'
                end
              end

              def api_post_body
                super.merge({
                  milestone_id: project_milestone.id
                })
              end
            end
          end
        end
      end
    end
  end
end
