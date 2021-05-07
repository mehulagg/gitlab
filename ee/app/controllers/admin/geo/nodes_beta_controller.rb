# frozen_string_literal: true

class Admin::Geo::NodesBetaController < Admin::Geo::ApplicationController
  before_action :check_license!

  def index
    redirect_to admin_geo_nodes_path if Feature.disabled?(:geo_nodes_beta)
  end
end
