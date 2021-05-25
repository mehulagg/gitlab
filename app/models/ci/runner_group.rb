# frozen_string_literal: true

module Ci
  class RunnerGroup < ApplicationRecord
    validates :name, uniqueness: true
  end
end
