# frozen_string_literal: true

class Groups::GroupMembersController < Groups::ApplicationController
  include MembershipActions
  include MembersPresentation
  include SortingHelper

  MEMBER_PER_PAGE_LIMIT = 50

  def self.admin_not_required_endpoints
    %i[index leave request_access]
  end

  helper_method :can_manage_members?

  # Authorize
  before_action :authorize_admin_group_member!, except: admin_not_required_endpoints

  skip_before_action :check_two_factor_requirement, only: :leave
  skip_cross_project_access_check :index, :invited, :create, :update, :destroy, :request_access,
                                  :approve_access_request, :leave, :resend_invite,
                                  :override

  feature_category :authentication_and_authorization

  def index
    @sort = params[:sort].presence || sort_value_name

    # tracked this back to https://gitlab.com/gitlab-org/gitlab/-/commit/aaa1c94239df831d10489d686d8883b49d601f43
    # where 'people/members' were attached to a project
    # no longer needed as @project isn't referenced
    # @project = @group.projects.find(params[:project_id]) if params[:project_id]

    @members = GroupMembersFinder
      .new(@group, current_user, params: filter_params)
      .execute(include_relations: requested_relations)

    if can_manage_members?
      @skip_groups = @group.related_group_ids
      #
      @invited_members = @members.invite
      # @invited_members = @invited_members.search_invite_email(params[:search_invited]) if params[:search_invited].present?
      # @invited_members = present_invited_members(@invited_members)
    end

    @members = present_group_members(@members.non_invite)

    @requesters = present_members(
      AccessRequestsFinder.new(@group).execute(current_user)
    )

    @group_member = @group.group_members.new
  end

  def invited
    @members = GroupMembersFinder
                 .new(@group, current_user, params: filter_params)
                 .execute(include_relations: requested_relations)

    @skip_groups = @group.related_group_ids
    @invited_members = @members.invite
    @invited_members = @invited_members.search_invite_email(params[:search_invited]) if params[:search_invited].present?
    @invited_members = present_invited_members(@invited_members)

    # @members = @members.non_invite
  end

  # MembershipActions concern
  alias_method :membershipable, :group

  private

  def can_manage_members?
    strong_memoize(:can_manage_members) do
      can?(current_user, :admin_group_member, @group)
    end
  end

  def present_invited_members(invited_members)
    present_members(invited_members.page(params[:invited_members_page]).per(MEMBER_PER_PAGE_LIMIT), admin: false)
  end

  def present_group_members(members)
    present_members(members.page(params[:page]).per(MEMBER_PER_PAGE_LIMIT), admin: false)
  end

  def filter_params
    params.permit(:two_factor, :search).merge(sort: @sort)
  end

  def membershipable_members
    group.members
  end
end

Groups::GroupMembersController.prepend_if_ee('EE::Groups::GroupMembersController')
