# frozen_string_literal: true

module Gitlab
  module Ci
    class Config
      module External
        class Reader
          def initialize(filepath, content)
            @filepath = filepath
            @content = content
          end

          def result
            file_content = Psych.parse(@content, filename: @filepath)
            class_loader = Psych::ClassLoader::Restricted.new(['Symbol'], [])
            scanner = Psych::ScalarScanner.new class_loader
            visitor = TrackedToRuby.new scanner, class_loader
            visitor.location_filename = @filepath
            visitor.accept file_content
          end
        end

        module ObjectWithLocation # < SimpleDelegator
          attr_accessor :location_filename, :location_line, :location_column #, :main_class

          # def is_a?(klass)
          #   main_class == klass
          # end
        end

        class TrackedToRuby < Psych::Visitors::ToRuby
          attr_accessor :location_filename

          def visit_Psych_Nodes_Scalar o
            value = super

            # result = ObjectWithLocation.new(value)
            # klass = Class.new(value.class) do
            #   attr_accessor :location_filename, :location_line, :location_column
            # end
            # byebug
            # result = klass.new(value)
            result = value.to_s.extend(ObjectWithLocation)
            result.location_filename = location_filename
            result.location_line = o.start_line..o.end_line
            result.location_column = o.start_column..o.end_column
            # result.main_class = value.class

            result
          end
        end
      end
    end
  end
end
