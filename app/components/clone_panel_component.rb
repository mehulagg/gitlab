# frozen_string_literal: true

class ClonePanelComponent < ApplicationComponent # rubocop:disable Gitlab/NamespacedClass
  include ApplicationSettingsHelper
  include ProjectsHelper

  attr_reader :current_user

  def initialize(current_user:, container:)
    @current_user = current_user
    @container = container
  end
end
