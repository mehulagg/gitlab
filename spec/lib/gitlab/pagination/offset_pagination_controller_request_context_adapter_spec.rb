# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Gitlab::Pagination::OffsetPaginationControllerRequestContextAdapter, type: :controller do
  controller(ProjectsController) do
    # fake controller action to test pagination and the headers
    def index
      relation = Project.order(:id)
      params_for_pagination = { per_page: 1, page: params[:page] || 0, other_param: 'test' }

      request_adapter = Gitlab::Pagination::OffsetPaginationControllerRequestContextAdapter.new(self, params_for_pagination)
      offset_pagination = Gitlab::Pagination::OffsetPagination.new(request_adapter)

      records = offset_pagination.paginate(relation, exclude_total_headers: true)

      render json: records.map(&:id)
    end
  end

  let_it_be(:projects) { create_list(:project, 2) }

  describe 'pagination' do
    it 'returns correct result for the first page' do
      get :index, params: { page: 1 }

      expect(json_response).to eq([projects.first.id])
    end

    it 'returns correct result for the second page' do
      get :index, params: { page: 2 }

      expect(json_response).to eq([projects.last.id])
    end
  end

  describe 'pagination heders' do
    it 'adds next page header' do
      get :index, params: { page: 1 }

      expect(response.headers['X-Next-Page']).to eq('2')
    end
  end
end
