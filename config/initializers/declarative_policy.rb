# frozen_string_literal: true

DeclarativePolicy.configure do
  named_policy :global, ::GlobalPolicy

  class_for do |name|
    ActiveSupport::Dependencies.interlock.permit_concurrent_loads { name.constantize }
  end
end
