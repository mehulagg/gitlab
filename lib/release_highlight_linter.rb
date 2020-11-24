# frozen_string_literal: true

class ReleaseHighlightLinter
  attr_reader :parsed

  def initialize(file:)
    @parsed = YAML.parse(File.read(file))
    @errors = []

    validate!

    return true if @errors.empty?

    raise "Validation failed for #{file}: #{@errors}"
  end

  def validate!
    #raise "Needs to be an array" if !first_child_is_sequence

    @parsed.children.first.children.each do |entry|
      EntryLinter.new(entry, @errors)
    end
  end

  #private

  #def first_child_is_sequence
    #@parsed.children.first.class == Psych::Nodes::Sequence
  #end

  class EntryLinter
    PACKAGES = %w(Core Starter Premium Ultimate)

    def initialize(entry, errors)
      @entry = entry
      @errors = errors

      validate!
    end

    def validate!
      #raise "needs to be a mapping" unless @entry.mapping?
      validate_string!('title')
      validate_string!('body')
      validate_string!('stage')
      validate_boolean!('self-managed')
      validate_boolean!('gitlab-com')
      validate_packages!
      validate_uri!('url')
      validate_uri!('image_url')
      validate_date!('published_at')
      validate_string!('release')
    end

    private

    def validate_packages!
      node = value_for('packages')

      unless node.is_a?(Psych::Nodes::Sequence)
        @errors.push("Line #{node.start_line} is invalid, packages must be a Sequence")
      end

      node.children.each do |child|
        unless PACKAGES.include?(child.value)
          add_error!(child, "must be one of #{PACKAGES}")
        end
      end
    end

    def validate_date!(key)
      node = value_for(key)
      Date.parse(node.value)

    rescue Date::Error
      @errors.push("#{line_value_error(node)}, must be a valid Date")
    end

    def validate_uri!(key)
      node = value_for(key)
      uri = URI.parse(node.value)
      push_errors = -> { @errors.push("#{line_value_error(node)}, must be a valid URL") }

      unless uri.host
        push_errors.call
      end
    rescue URI::InvalidURIError
      push_errors.call
    end

    def validate_boolean!(key)
      node = value_for(key)

      unless ["true", "false"].include?(node.value)
        add_error!(node, 'must be a Boolean')
      end
    end

    def validate_string!(key)
      node = value_for(key)

      unless node.value.is_a?(String)
        add_error!(node, "must be a String")
      end
    end

    def value_for(key)
      attribute = @entry.children.find {|node| node.try(:value) == key }
      index = @entry.children.find_index(attribute)
      @entry.children[index + 1]
    end

    def add_error!(node, message)
      @errors.push("#{line_value_error(node)}, #{message}")
    end

    def line_value_error(node)
      "Value at line #{node.start_line} \"#{node.value}\" is invalid"
    end
  end
end
