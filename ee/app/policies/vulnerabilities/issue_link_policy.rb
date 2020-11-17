# frozen_string_literal: true

module Vulnerabilities
  class IssueLinkPolicy < BasePolicy
    delegate { @subject.vulnerability&.project }
  end
end
