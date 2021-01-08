# frozen_string_literal: true
module Packages
  class PackageTagPolicy < BasePolicy
    delegate { @subject.package.project }
  end
end
