# frozen_string_literal: true

class GeoNodeFinder
  include Gitlab::Allowable

  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params
  end

  def execute
    return GeoNode.none unless can?(current_user, :read_all_geo)

    geo_nodes = init_collection

    geo_nodes = by_id(geo_nodes)
    geo_nodes = by_name(geo_nodes)

    geo_nodes.ordered
  end

  private

  attr_reader :current_user, :params

  def init_collection
    GeoNode.all
  end

  def by_id(geo_nodes)
    return geo_nodes unless params[:ids]

    geo_nodes.id_in(params[:ids])
  end

  def by_name(geo_nodes)
    return geo_nodes unless params[:names]

    geo_nodes.name_in(params[:names])
  end
end
