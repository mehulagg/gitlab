# frozen_string_literal: true

module Sidebars
  class MenuItem
    extend ::Gitlab::Utils::Override
    include ::Gitlab::Routing
    include GitlabRoutingHelper
    include Gitlab::Allowable

    attr_reader :context, :title, :link, :active_routes, :item_id, :html_options, :sprite_icon, :hint_html_options

    def initialize(title:, link:, active_routes:, item_id: nil, html_options: {}, sprite_icon: nil, hint_html_options: {})
      @title = title
      @link = link
      @active_routes = active_routes
      @item_id = item_id
      @html_options = html_options
      @sprite_icon = sprite_icon
      @hint_html_options = hint_html_options
    end

    def show_hint?
      hint_html_options.present?
    end

    def show_sprite_icon?
      sprite_icon.present?
    end
  end
end
