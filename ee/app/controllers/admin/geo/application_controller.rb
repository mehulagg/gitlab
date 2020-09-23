# frozen_string_literal: true

class Admin::Geo::ApplicationController < Admin::ApplicationController
  helper ::EE::GeoHelper

  protected

  def check_license!
    unless Gitlab::Geo.license_allows?
      render_403
    end
  end
end
