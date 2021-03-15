# frozen_string_literal: true

# Concern for handling deprecation arguments.
# https://docs.gitlab.com/ee/development/api_graphql_styleguide.html#deprecating-fields-and-enum-values
module GitlabStyleDeprecations
  extend ActiveSupport::Concern

  REASONS = {
    renamed: 'This was renamed.',
    discouraged: 'Use of this is not recommended.'
  }.freeze

  private

  # Mutate the arguments, returns the deprecation
  def gitlab_deprecation(kwargs)
    if kwargs[:deprecation_reason].present?
      raise ArgumentError, 'Use `deprecated` property instead of `deprecation_reason`. ' \
                           'See https://docs.gitlab.com/ee/development/api_graphql_styleguide.html#deprecating-fields-arguments-and-enum-values'
    end

    deprecation = kwargs.delete(:deprecated)
    return unless deprecation

    milestone, reason = deprecation.values_at(:milestone, :reason).map(&:presence)

    raise ArgumentError, 'Please provide a `milestone` within `deprecated`' unless milestone
    raise ArgumentError, 'Please provide a `reason` within `deprecated`' unless reason
    raise ArgumentError, '`milestone` must be a `String`' unless milestone.is_a?(String)

    reason = REASONS.key?(reason) ? REASONS[reason] : reason.to_s.strip
    deprecation[:reason_text] = reason
    deprecation.freeze

    replacement = deprecation[:replacement]
    reason += " Please use `#{replacement}`." if replacement.present?
    deprecated_in = "Deprecated in #{milestone}"

    kwargs[:deprecation_reason] = "#{reason} #{deprecated_in}."
    kwargs[:description] += " #{deprecated_in}: #{reason}" if kwargs[:description]

    deprecation
  end
end
