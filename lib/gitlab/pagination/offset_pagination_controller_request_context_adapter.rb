# frozen_string_literal: true

module Gitlab
  module Pagination
    # This class makes it possible to expose the standard response headers for pagination in rails controllers
    #
    # The class takes the controller instance and the params that are needed to build the pagination links
    #
    # Usage example:
    #
    # def index
    #   relation = Project.where({})
    #   params_for_pagination = { per_page: 20, page: params[:page] || 0, other_param: 'test' }
    #
    #   request_adapter = Gitlab::Pagination::OffsetPaginationControllerRequestContextAdapter.new(self, params_for_pagination)
    #   offset_pagination = Gitlab::Pagination::OffsetPagination.new(request_adapter)
    #
    #   records = offset_pagination.paginate(relation, exclude_total_headers: true) # adds the headers
    # end
    class OffsetPaginationControllerRequestContextAdapter < SimpleDelegator
      attr_reader :params

      def initialize(controller, params)
        super(controller)
        @params = params
      end

      def header(name, value)
        response.headers[name] = value
      end
    end
  end
end
