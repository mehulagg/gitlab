# frozen_string_literal: true

module Gitlab
  module Graphql
    module Queries
      IMPORT_RE = /^#import "(?<path>[^"]+)"$/m.freeze
      HOME_RE = /^~/.freeze
      DOTS_RE = %r{^(\.\./)+}.freeze
      DOT_RE = %r{^\./}.freeze
      IMPLICIT_ROOT = %r{^app/}.freeze

      class Definition
        attr_reader :file, :imports

        def initialize(path, fragments)
          @file = path
          @fragments = fragments
          @imports = []
          @errors = []
        end

        def text
          qs = [query] + all_imports.uniq.sort.map { |p| @fragments.get(p).query }
          qs.join("\n\n").gsub(/\n\n+/, "\n\n")
        end

        def query
          @query ||= File.read(file).gsub(IMPORT_RE) do
            @imports << fragment_path($~[:path])

            ''
          end
        end

        def all_imports
          return [] if query.nil?

          imports
            .flat_map { |p| [p] + @fragments.get(p).all_imports }
        end

        def fragment_path(import_path)
          frag_path = import_path.gsub(HOME_RE, @fragments.home)
          frag_path = frag_path.gsub(DOT_RE) do
            Pathname.new(file).parent.to_s + '/'
          end
          frag_path = frag_path.gsub(DOTS_RE) do |dots|
            rel_dir(dots.split('/').count)
          end
          frag_path = frag_path.gsub(IMPLICIT_ROOT) do
            (Rails.root / 'app').to_s + '/'
          end

          frag_path
        end

        def rel_dir(n_steps_up)
          path = Pathname.new(file).parent
          while n_steps_up > 0
            path = path.parent
            n_steps_up -= 1
          end

          path.to_s + '/'
        end

        def validate(schema)
          schema.validate(query).each do |err|
            warn(<<~MSG)
            #{file}: #{err.message} (at #{err.path.join('.')})
            MSG
          end
        end
      end

      class Fragments
        def initialize
          @store = {}
        end

        def home
          @home ||= (Rails.root / 'app/assets/javascripts').to_s
        end

        def get(frag_path)
          @store[frag_path] ||= Definition.new(frag_path, self)
        end
      end

      def self.all
        fragments = Fragments.new

        ['.', 'ee'].flat_map do |prefix|
          root = Rails.root / prefix / 'app/assets/javascripts'
          definitions = []

          Find.find(root) do |path|
            next unless path.endwith?('.graphql')

            definitions << Definition.new(path, fragments)
          end

          definitions
        end
      end
    end
  end
end
