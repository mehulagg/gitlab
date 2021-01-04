# frozen_string_literal: true

class Admin::Geo::NodesBetaController < Admin::Geo::ApplicationController
  before_action :check_license!

  def index
    unless Feature.enabled?(:geo_nodes_beta)
      redirect_to admin_geo_nodes_path
    end
  end
end
