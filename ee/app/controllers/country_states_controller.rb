# frozen_string_literal: true

class CountryStatesController < ActionController::Metal
  include AbstractController::Rendering
  include ActionController::ApiRendering
  include ActionController::Renderers

  use_renderers :json

  def index
    country = params[:country]
    states = World.states_for_country(country)

    render json: states, status: (states ? :ok : :not_found)
  end
end
