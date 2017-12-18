module EE
  module Boards
    module Issues
      module ListService
        def set_parent
          if parent.is_a?(Group)
            params[:group_id] = parent.id
          else
            super
          end
        end

        def issues_label_links
          if has_valid_milestone?
            super.where("issues.milestone_id = ?", board.milestone_id)
          else
            super
          end
        end

        private

        # Prevent filtering by milestone stubs
        # like Milestone::Upcoming, Milestone::Started etc
        def has_valid_milestone?
          return false unless board.milestone

          !::Milestone.predefined?(board.milestone)
        end
      end
    end
  end
end
