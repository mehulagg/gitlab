# frozen_string_literal: true

module Iterations
  class CadencePolicy < BasePolicy
    delegate { @subject.group }
  end
end
