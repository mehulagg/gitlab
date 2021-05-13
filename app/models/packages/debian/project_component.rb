# frozen_string_literal: true

class Packages::Debian::ProjectComponent < NamespaceShard
  def self.container_type
    :project
  end

  include Packages::Debian::Component
end
