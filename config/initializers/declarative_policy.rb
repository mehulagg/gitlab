# frozen_string_literal: true

DeclarativePolicy.configure do
  named_policy :global, ::GlobalPolicy

  class_for(&:constantize)
end
