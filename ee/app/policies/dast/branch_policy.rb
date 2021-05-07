# frozen_string_literal: true

module Dast
  class BranchPolicy < BasePolicy
    delegate { @subject.project }
  end
end
