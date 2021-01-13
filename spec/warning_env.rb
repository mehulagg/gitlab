# frozen_string_literal: true

require 'warning'

Warning.process('', keyword_separation: :raise)

# Ignore keyword warnings in Gem dependencies, for now
Gem.path.each do |path|
  Warning.ignore(:keyword_separation, path)
end
