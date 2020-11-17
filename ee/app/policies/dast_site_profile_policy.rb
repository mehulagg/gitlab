# frozen_string_literal: true

class DastSiteProfilePolicy < BasePolicy
  delegate { @subject.project }
end
