# frozen_string_literal: true

class CountriesController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::ApiRendering
  include ActionController::Renderers

  use_renderers :json

  def index
    countries = World.countries_for_select

    render json: countries, status: (countries ? :ok : :not_found)
  end
end
