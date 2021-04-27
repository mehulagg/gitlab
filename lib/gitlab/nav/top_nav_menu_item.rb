# frozen_string_literal: true

module Gitlab
  module Nav
    class TopNavMenuItem
      attr_reader :id
      attr_reader :title
      attr_reader :active
      attr_reader :icon
      attr_reader :href
      attr_reader :view
      attr_reader :method
      attr_reader :class
      attr_reader :data

      def initialize(id:, title:, active: false, icon: '', href: '', method: nil, view: '', **attrs)
        @id = id
        @title = title
        @active = active
        @icon = icon
        @href = href
        @method = method
        @view = view
        @class = attrs.fetch(:class, '')
        @data = attrs.fetch(:data, {})
      end
    end
  end
end
