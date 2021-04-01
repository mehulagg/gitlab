# frozen_string_literal: true

module Gitlab
  module Database
    module LoadBalancing
      class Tracing < SimpleDelegator
        def initialize(session)
          @session = session
          @trace = []

          super(session)
        end

        def log_session_trace!(context)
          LoadBalancing::Logger.info(
            event: :session_trace,
            context: context,
            trace: @trace.join('->')
          )
        end

        def use_primary!(namespace = nil)
          @trace.push("sticking to #{namespace}")

          super
        end

        def use_primary(&blk)
          @trace.push('primary db block')

          super
        end

        def write!
          if @session.ignore_writes?
            @trace.push('performed ignored write')
          else
            @trace.push('performed write')
          end

          super
        end
      end
    end
  end
end
