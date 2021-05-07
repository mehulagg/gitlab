# frozen_string_literal: true

module Dast
  class ProfilePolicy < BasePolicy
    delegate { @subject.project }
  end
end
