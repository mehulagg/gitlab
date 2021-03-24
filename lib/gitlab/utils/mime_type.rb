# frozen_string_literal: true

module Gitlab
  module Utils
    class MimeType
      Error = Class.new(StandardError)

      class << self
        # Implementation taken from https://github.com/shrinerb/shrine/blob/master/lib/shrine/plugins/determine_mime_type.rb
        def from_io(io)
          require "open3"

          return nil if io.eof? # file command returns "application/x-empty" for empty files

          Open3.popen3(*%W[file --mime-type --brief -]) do |stdin, stdout, stderr, thread|
            begin
              IO.copy_stream(io, stdin.binmode)
            rescue Errno::EPIPE
            end
            stdin.close

            status = thread.value

            raise Error, "file command failed to spawn: #{stderr.read}" if status.nil?
            raise Error, "file command failed: #{stderr.read}" unless status.success?

            $stderr.print(stderr.read)

            output = stdout.read.strip

            raise Error, "file command failed: #{output}" if output.include?("cannot open")

            output
          end
        rescue Errno::ENOENT
          raise Error, "file command-line tool is not installed"
        end
      end
    end
  end
end
