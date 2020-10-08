# frozen_string_literal: true

class WhatsNewController < ApplicationController
  include Gitlab::WhatsNew

  skip_before_action :authenticate_user!

  before_action :check_feature_flag, :set_pagination_headers

  feature_category :navigation

  def index
    respond_to do |format|
      format.js do
        page = params[:page] || 1
        render json: whats_new_release_items(page: page.to_i)
      end
    end
  end

  private

  def check_feature_flag
    render_404 unless Feature.enabled?(:whats_new_drawer, current_user)
  end

  def set_pagination_headers
    response.set_header('X-Page', params[:page] || 1)
    response.set_header('X-Next-Page', next_page)
  end

  def next_page
    page = params[:page] || 1
    next_page = page.to_i + 1
    index = next_page - 1

    next_page if most_recent_release_file_paths[index]
  end
end
