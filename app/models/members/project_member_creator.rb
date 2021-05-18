# frozen_string_literal: true

module Members
  class ProjectMemberCreator < Creator
    private

    def access_levels
      Gitlab::Access.sym_options
    end

    def can_update_member?
      # There is no current user for bulk actions, in which case anything is allowed
      !current_user || current_user.can?(:update_project_member, member) || (member.owner? && member.new_record?)
    end
  end
end
