# frozen_string_literal: true

class DastScannerProfilePolicy < BasePolicy
  delegate { @subject.project }
end
