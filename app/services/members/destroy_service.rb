module Members
  class DestroyService < BaseService
    include MembersHelper

    attr_accessor :source

    ALLOWED_SCOPES = %i[members requesters all].freeze

    def initialize(source, current_user, params = {})
      @source = source
      @current_user = current_user
      @params = params
    end

    def execute(scope = :members)
      raise "scope :#{scope} is not allowed!" unless ALLOWED_SCOPES.include?(scope)

      member = find_member!(scope)

      raise Gitlab::Access::AccessDeniedError unless can_destroy_member?(member)

      AuthorizedDestroyService.new(member, current_user).execute

      AuditEventService.new(@current_user, @source, action: :destroy)
        .for_member(member).security_event

      member
    end

    private

    def find_member!(scope)
      condition = params[:user_id] ? { user_id: params[:user_id] } : { id: params[:id] }
      case scope
      when :all
        source.members.find_by(condition) ||
          source.requesters.find_by!(condition)
      else
        source.public_send(scope).find_by!(condition) # rubocop:disable GitlabSecurity/PublicSend
      end
    end

    def can_destroy_member?(member)
      member && can?(current_user, destroy_member_permission(member), member)
    end

    def destroy_member_permission(member)
      case member
      when GroupMember
        :destroy_group_member
      when ProjectMember
        :destroy_project_member
      end
    end
  end
end
