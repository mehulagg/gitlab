# frozen_string_literal: true

module Sidebars
  class MenuItem
    attr_reader :title, :link, :active_routes, :item_id, :container_html_options, :sprite_icon, :sprite_icon_html_options, :hint_html_options, :render

    # rubocop:disable Metrics/ParameterLists
    def initialize(title:, link:, active_routes:, item_id: nil, container_html_options: {}, sprite_icon: nil, sprite_icon_html_options: {}, hint_html_options: {}, render: -> { true })
      @title = title
      @link = link
      @active_routes = active_routes
      @item_id = item_id
      @container_html_options = { aria: { label: title } }.merge(container_html_options)
      @sprite_icon = sprite_icon
      @sprite_icon_html_options = sprite_icon_html_options
      @hint_html_options = hint_html_options
      @render = render.call
    end
    # rubocop:enable Metrics/ParameterLists

    def show_hint?
      hint_html_options.present?
    end
  end
end
