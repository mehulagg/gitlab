# frozen_string_literal: true

if ENV['RECORD_KEYWORD_WARNINGS']
  require 'warning'

  Warning[:deprecated] = true

  # The warnings are emitted with two calls of Warning.warn.
  # In an attempt to group these two calls we use the `----` separator.

  keyword_regex = /: warning: (?:Using the last argument (?:for `.+' )?as keyword parameters is deprecated; maybe \*\* should be added to the call)\n\z/
  method_called_regex = /: warning: (?:The called method (?:`.+' )?is defined here)\n\z/
  actions = {
    keyword_regex => proc do |warning|
      File.open(File.expand_path('../tmp/keyword_warn.txt', __dir__), "a") do |file|
        file.write("----\n")
        file.write(warning)

        # keep ruby behaviour of warning in stderr
        $stderr.puts(warning) # rubocop:disable Style/StderrPuts
      end
    end,
    method_called_regex => proc do |warning|
      File.open(File.expand_path('../tmp/keyword_warn.txt', __dir__), "a") do |file|
        file.write(warning)

        # keep ruby behaviour of warning in stderr
        $stderr.puts(warning) # rubocop:disable Style/StderrPuts
      end
    end
  }
  Warning.process('', actions)
end
