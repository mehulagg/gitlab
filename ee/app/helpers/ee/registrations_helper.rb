# frozen_string_literal: true

module EE
  module RegistrationsHelper
    include ::Gitlab::Utils::StrongMemoize

    def visibility_level_options
      available_visibility_levels(@group).map do |level|
        {
          level: level,
          label: visibility_level_label(level),
          description: visibility_level_description(level, @group)
        }
      end
    end

    private

    def redirect_path
      strong_memoize(:redirect_path) do
        redirect_to = session['user_return_to']
        URI.parse(redirect_to).path if redirect_to
      end
    end
  end
end
