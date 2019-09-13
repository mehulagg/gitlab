# frozen_string_literal: true

# In this class we keep track of the state changes that the
# Converter makes as it scans through the log stream.
module Gitlab
  module Ci
    module Ansi2json
      class State
        attr_accessor :offset, :current_line, :inherited_style, :open_sections, :last_line_offset

        def initialize
          reset!
        end

        def restore(new_state, stream_size)
          reset!

          if new_state.present?
            state = Base64.urlsafe_decode64(new_state)
            state = JSON.parse(state)
            return if state['offset'].to_i > stream_size

            @offset = state['offset'] if state['offset']
            @open_sections = state['open_sections'] if state['open_sections']

            if state['style']
              @inherited_style = {
                fg: state.dig('style', 'fg'),
                bg: state.dig('style', 'bg'),
                mask: state.dig('style', 'mask')
              }
            end
          end
        end

        def encode
          state = {
            offset: @last_line_offset,
            style: @current_line.style.to_h,
            open_sections: @open_sections
          }
          Base64.urlsafe_encode64(state.to_json)
        end

        def open_section(section, timestamp)
          @open_sections[section] = timestamp

          @current_line.add_section(section)
          @current_line.set_as_section_header
        end

        def close_section(section, timestamp)
          return unless section_open?(section)

          duration = timestamp.to_i - @open_sections[section].to_i
          @current_line.set_section_duration(duration)

          @open_sections.delete(section)
        end

        def section_open?(section)
          @open_sections[section]
        end

        def set_current_line!(style: nil, advance_offset: 0)
          new_line = Line.new(
            offset: @offset + advance_offset,
            style: style || @current_line.style,
            sections: @open_sections.keys
          )
          @current_line = new_line
        end

        def set_last_line_offset
          @last_line_offset = @current_line.offset
        end

        def update_style(commands)
          @current_line.flush_current_segment!
          @current_line.update_style(commands)
        end

        private

        def reset!
          @offset = 0
          @inherited_style = {}

          # in case of nested sections this will point to the
          # most indented section
          @open_sections = {}
        end
      end
    end
  end
end
