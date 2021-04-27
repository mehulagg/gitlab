# frozen_string_literal: true

module Gitlab
  module Pagination
    module Keyset
      module Paginatable
        extend ActiveSupport::Concern

        FORWARD_DIRECTION = 'n'
        BACKWARD_DIRECTION = 'p'

        included do
          extend ::Gitlab::Utils::Override
          include Enumerable
          attr_reader :keyset_scope, :per_page, :cursor_converter, :direction_key, :cursor_attributes

          delegate :each, :empty?, :any?, to: :records
        end

        module Base64CursorConverter
          def self.dump(cursor_attributes)
            Base64.urlsafe_encode64(Gitlab::Json.dump(cursor_attributes))
          end

          def self.parse(cursor)
            Gitlab::Json.parse(Base64.urlsafe_decode64(cursor)).with_indifferent_access
          end
        end

        class PaginationState
          attr_accessor :direction, :has_another_page, :at_last_page, :at_first_page

          def initialize
            @direction = FORWARD_DIRECTION
            @has_another_page = false
            @at_last_page = false
            @at_first_page = false
          end
        end

        attr_reader :state

        # rubocop: disable Gitlab/ModuleWithInstanceVariables
        def setup_pagination_variables(cursor, per_page, cursor_converter, direction_key)
          @per_page = per_page
          @cursor_converter = cursor_converter
          @direction_key = direction_key
          @state = PaginationState.new
          @cursor_attributes = decode_cursor_attributes(cursor)

          set_pagination_helper_flags!
        end
        # rubocop: enable Gitlab/ModuleWithInstanceVariables

        # Returns the records for the current page
        def records
          raise NotImplementedError
        end

        # Returns the keyset order object
        def order
          raise NotImplementedError
        end

        # This and has_previous_page? methods are direction aware. In case we paginate backwards,
        # has_next_page? will mean that we have a previous page.
        def has_next_page?
          records

          if at_last_page?
            false
          elsif paginate_forward?
            state.has_another_page
          elsif paginate_backward?
            true
          end
        end

        def has_previous_page?
          records

          if at_first_page?
            false
          elsif paginate_backward?
            state.has_another_page
          elsif paginate_forward?
            true
          end
        end

        def cursor_for_next_page
          if has_next_page?
            data = order.cursor_attributes_for_node(records.last)
            data[direction_key] = FORWARD_DIRECTION
            cursor_converter.dump(data)
          end
        end

        def cursor_for_previous_page
          if has_previous_page?
            data = order.cursor_attributes_for_node(records.first)
            data[direction_key] = BACKWARD_DIRECTION
            cursor_converter.dump(data)
          end
        end

        def cursor_for_first_page
          cursor_converter.dump({ direction_key => FORWARD_DIRECTION })
        end

        def cursor_for_last_page
          cursor_converter.dump({ direction_key => BACKWARD_DIRECTION })
        end

        def decode_cursor_attributes(cursor)
          cursor.blank? ? {} : cursor_converter.parse(cursor)
        end

        def set_pagination_helper_flags!
          state.direction = cursor_attributes.delete(direction_key.to_s)

          if cursor_attributes.blank? && state.direction.blank?
            state.at_first_page = true
            state.direction = FORWARD_DIRECTION
          elsif cursor_attributes.blank?
            if paginate_forward?
              state.at_first_page = true
            else
              state.at_last_page = true
            end
          end
        end

        def at_last_page?
          state.at_last_page
        end

        def at_first_page?
          state.at_first_page
        end

        def per_page_plus_one
          per_page + 1
        end

        def paginate_backward?
          state.direction == BACKWARD_DIRECTION
        end

        def paginate_forward?
          state.direction == FORWARD_DIRECTION
        end
      end
    end
  end
end
