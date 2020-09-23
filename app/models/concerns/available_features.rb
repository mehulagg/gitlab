# frozen_string_literal: true

# Verifies features availability based on issue type.
# This can be used, for example, for hiding UI elements or blocking specific
# quick actions for particular issue types;
module AvailableFeatures
  include Gitlab::Utils::StrongMemoize

  def type_supports?(feature)
    !blocked_features_by_type[issue_type]&.include?(feature.to_sym)
  end

  def blocked_features_by_type
    strong_memoize(:blocked_features_by_type) do
      {
        incident: %i(promotion),
        test_case: %i(promotion)
      }.with_indifferent_access
    end
  end
end
