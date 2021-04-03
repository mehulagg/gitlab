# frozen_string_literal: true

module Vulnerabilities
  class ExternalIssueLinkPolicy < BasePolicy
    delegate { @subject.vulnerability.project }
  end
end
