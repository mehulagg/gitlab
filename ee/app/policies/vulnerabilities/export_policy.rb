# frozen_string_literal: true

module Vulnerabilities
  class ExportPolicy < BasePolicy
    delegate { @subject.exportable }

    condition(:is_author) { @user && @subject.author == @user }
    condition(:exportable) { can?(:create_vulnerability_export, @subject.exportable) }

    rule { exportable & is_author }.policy do
      enable :read_vulnerability_export
    end
  end
end
