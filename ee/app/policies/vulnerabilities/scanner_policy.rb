# frozen_string_literal: true

module Vulnerabilities
  class ScannerPolicy < BasePolicy
    delegate { @subject.project }
  end
end
