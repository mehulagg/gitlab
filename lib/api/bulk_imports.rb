# frozen_string_literal: true

module API
  class BulkImports < ::API::Base
    include PaginationParams

    feature_category :importers

    before { authenticate! }

    namespace 'bulk_imports' do
      desc 'Get list of all bulk imports' do
        detail 'This feature was introduced in GitLab 14.1.'
      end
      params do
        use :pagination
        optional :status, type: String, values: BulkImport.all_human_statuses,
                 desc: 'Return bulk imports with specified status'
      end
      get do
        bulk_imports = ::BulkImports::ImportsFinder.new(current_user, params[:status]).execute

        present paginate(bulk_imports), with: Entities::BulkImports::Import
      end

      desc "Get list of all bulk imports' entities" do
        detail 'This feature was introduced in GitLab 14.1.'
      end
      params do
        use :pagination
        optional :status, type: String, values: ::BulkImports::Entity.all_human_statuses,
                 desc: 'Return bulk imports with specified status'
      end
      get '/entities' do
        bulk_imports = current_user.bulk_imports

        present paginate(bulk_imports), with: Entities::BulkImports::Import
      end
    end
  end
end
