# frozen_string_literal: true

module Analytics
  module Deployments
    class Frequency
      include ActiveModel::Model

      attr_accessor :contianer, :value, :from, :to
    end
  end
end
