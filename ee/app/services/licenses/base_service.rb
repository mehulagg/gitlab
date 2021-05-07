# frozen_string_literal: true

module Licenses
  class BaseService
    include Gitlab::Allowable

    def initialize(license, user)
      @license = license
      @user = user
    end

    def execute
      raise NotImplementedError
    end

    private

    attr_reader :license, :user
  end
end
