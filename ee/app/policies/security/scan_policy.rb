# frozen_string_literal: true

module Security
  class ScanPolicy < BasePolicy
    delegate { @subject.project }

    rule { can?(:read_vulnerability) }.policy do
      enable :read_scan
    end
  end
end
