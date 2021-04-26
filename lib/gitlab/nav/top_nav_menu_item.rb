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

      # This is a PORO. We want to have all keyword arguments for type safety.
      # Ordinarily we could introduce a params object, but that's kind of what
      # this is already :/. We could also take a hash and manually check every
      # entry, but it's much more maintainable to do rely on native Ruby.
      # rubocop: disable Metrics/ParameterLists
      def initialize(id:, title:, active: false, icon: '', href: '', method: nil, view: '', css_class: '', data: {})
        @id = id
        @title = title
        @active = active
        @icon = icon
        @href = href
        @method = method
        @view = view
        @class = css_class
        @data = data
      end
      # rubocop: enable Metrics/ParameterLists
    end
  end
end
