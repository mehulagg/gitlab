module EE
  module Projects
    module MergeRequestsController
      extend ActiveSupport::Concern

      def approve
        unless merge_request.can_approve?(current_user)
          return render_404
        end

        ::MergeRequests::ApprovalService
          .new(project, current_user)
          .execute(merge_request)

        render_approvals_json
      end

      def approvals
        render_approvals_json
      end

      def unapprove
        if merge_request.has_approved?(current_user)
          ::MergeRequests::RemoveApprovalService
            .new(project, current_user)
            .execute(merge_request)
        end

        render_approvals_json
      end

      protected

      def define_edit_vars
        super

        set_suggested_approvers
      end

      def render_approvals_json
        respond_to do |format|
          format.json do
            entity = ::API::Entities::MergeRequestApprovals.new(merge_request, current_user: current_user)
            render json: entity
          end
        end
      end

      def merge_params_attributes
        attrs = super
        attrs << :squash if project.feature_available?(:merge_request_squash)

        attrs
      end
    end
  end
end
