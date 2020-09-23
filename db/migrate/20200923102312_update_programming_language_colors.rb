# frozen_string_literal: true
require 'yaml'

class UpdateProgrammingLanguageColors < ActiveRecord::Migration[6.0]
  DOWNTIME = false

  def up
    YAML.load_file("vendor/languages.yml").each do |name, metadata|
      color = metadata["color"]
      next if color.nil? || color.empty?

      quoted_name = name.gsub(/\\/, '\&\&').gsub(/'/, "''")
      execute("UPDATE programming_languages SET color = '#{color}' WHERE name = '#{quoted_name}';")
    end
  end

  def down
    # noop
  end
end
