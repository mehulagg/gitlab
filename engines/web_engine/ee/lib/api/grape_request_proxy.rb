# frozen_string_literal: true

module API
  # GrapeRequestProxy provides a similar interface to ActionDispatch::Request,
  # allowing usage of a serializer with `RequestAwareEntity` within a Grape API
  class GrapeRequestProxy < SimpleDelegator
    attr_reader :current_user

    def initialize(req, current_user)
      @current_user = current_user
      super(req)
    end
  end
end
