# frozen_string_literal: true

class DastScanPolicy < BasePolicy
  delegate { @subject.project }
end
