# frozen_string_literal: true

module BulkImports
  module Configs
    extend self

    def config_for(portable)
      case portable
      when ::Project
        Configs::ProjectConfig.new(portable)
      when ::Group
        Configs::GroupConfig.new(portable)
      end
    end
  end
end
