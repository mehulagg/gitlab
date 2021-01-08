# frozen_string_literal: true
module Packages
  class PackageComposerJsonPolicy < BasePolicy
    delegate { @subject.package.project }
  end
end
