# frozen_string_literal: true

module API
  class GroupExport < ::API::Base
    helpers Helpers::RateLimiter

    before do
      not_found! unless Feature.enabled?(:group_import_export, user_group, default_enabled: true)

      authorize! :admin_group, user_group
    end

    feature_category :importers

    params do
      requires :id, type: String, desc: 'The ID of a group'
    end
    resource :groups, requirements: { id: %r{[^/]+} } do
      desc 'Download export' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      get ':id/export/download' do
        check_rate_limit! :group_download_export, [current_user, user_group]

        if user_group.export_file_exists?
          present_carrierwave_file!(user_group.export_file)
        else
          render_api_error!('404 Not found or has expired', 404)
        end
      end

      desc 'Start export' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      post ':id/export' do
        check_rate_limit! :group_export, [current_user]

        export_service = ::Groups::ImportExport::ExportService.new(group: user_group, user: current_user)

        if export_service.async_execute
          accepted!
        else
          render_api_error!(message: 'Group export could not be started.')
        end
      end

      desc 'Download relations export' do
        detail 'This feature was introduced in GitLab TBD'
      end
      params do
        requires :relation, type: String, desc: 'Group relation name'
      end
      get ':id/export_relations/download' do
        # TBD
      end

      desc 'Relations export status' do
        detail 'This feature was introduced in GitLab TBD'
      end
      get ':id/export_relations/status' do
        # TBD
      end

      desc 'Start relations export' do
        detail 'This feature was introduced in GitLab 12.5.'
      end
      post ':id/export_relations' do
        response = ::BulkImports::ExportService.new(exportable: user_group, user: current_user).execute

        if response.success?
          render json: :ok
        else
          render json: { error: response.message }, status: response.http_status
        end
      end
    end
  end
end
