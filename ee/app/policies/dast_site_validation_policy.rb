# frozen_string_literal: true

class DastSiteValidationPolicy < BasePolicy
  delegate { @subject.dast_site_token.project }
end
