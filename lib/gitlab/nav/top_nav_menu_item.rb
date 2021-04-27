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

      def initialize(id:, title:, active: false, icon: '', href: '', view: '')
        @id = id
        @title = title
        @active = active
        @icon = icon
        @href = href
        @view = view
      end
    end
  end
end
