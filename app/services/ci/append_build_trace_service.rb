# frozen_string_literal: true

module Ci
  class AppendBuildTraceService
    Result = Struct.new(:status, :stream_size, keyword_init: true)
    TraceRangeError = Class.new(StandardError)

    attr_reader :build, :range

    def initialize(build, range:)
      @build = build
      @range = range
    end

    def execute(body_data)
      # TODO:
      # it seems that `Content-Range` as formatted by runner is wrong,
      # the `byte_end` should point to final byte, but it points byte+1
      # that means that we have to calculate end of body,
      # as we cannot use `content_length[1]`
      # Issue: https://gitlab.com/gitlab-org/gitlab-runner/issues/3275

      content_range = range.split('-')
      body_start = content_range[0].to_i
      body_end = body_start + body_data.bytesize

      stream_size = build.trace.append(body_data, body_start)

      unless stream_size == body_end
        ::Gitlab::ErrorTracking.log_exception(TraceRangeError.new,
          build_id: build.id,
          stream_size: stream_size,
          stream_class: stream_size.class,
          chunks_count: build.trace_chunks.count,
          chunks_index: build.trace_chunks.last&.chunk_index
        )

        return Result.new(status: 416, stream_size: stream_size)
      end

      Result.new(status: 202, stream_size: stream_size)
    end
  end
end
