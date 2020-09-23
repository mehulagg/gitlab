# frozen_string_literal: true

class Admin::Geo::ReplicablesController < Admin::Geo::ApplicationController
  before_action :check_license!
  before_action :set_replicator_class, only: :index

  def index
  end

  def set_replicator_class
    replicable_name = params[:replicable_name_plural].singularize

    @replicator_class = Gitlab::Geo::Replicator.for_replicable_name(replicable_name)
  rescue NotImplementedError
    render_404
  end
end
