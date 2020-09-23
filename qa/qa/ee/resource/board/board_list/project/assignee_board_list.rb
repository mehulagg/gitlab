# frozen_string_literal: true

module QA
  module EE
    module Resource
      module Board
        module BoardList
          module Project
            class AssigneeBoardList < BaseBoardList
              attribute :assignee

              def api_post_body
                super.merge({
                  assignee_id: assignee.id
                })
              end
            end
          end
        end
      end
    end
  end
end
