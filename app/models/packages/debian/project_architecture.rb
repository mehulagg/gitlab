# frozen_string_literal: true

class Packages::Debian::ProjectArchitecture < NamespaceShard
  def self.container_type
    :project
  end

  include Packages::Debian::Architecture
end
