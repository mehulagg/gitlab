# frozen_string_literal: true

class Packages::Debian::ProjectComponentFile < NamespaceShard
  def self.container_type
    :project
  end

  include Packages::Debian::ComponentFile
end
