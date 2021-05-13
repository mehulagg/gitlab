# frozen_string_literal: true

class Packages::Debian::GroupArchitecture < NamespaceShard
  def self.container_type
    :group
  end

  include Packages::Debian::Architecture
end
