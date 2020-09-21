# frozen_string_literal: true

class WhatsNewController < ApplicationController
  include Gitlab::WhatsNew

  skip_before_action :authenticate_user!

  def index
    respond_to do |format|
      format.js do
        render json: whats_new_most_recent_release_items
      end
    end
  end
end
