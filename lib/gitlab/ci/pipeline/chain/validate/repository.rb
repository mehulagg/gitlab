# frozen_string_literal: true

module Gitlab
  module Ci
    module Pipeline
      module Chain
        module Validate
          class Repository < Chain::Base
            include Chain::Helpers

            def perform!
              if @command.package_push
                unless @command.package_push.valid?
                  return error('Package push invalid')
                end
              else
                unless @command.branch_exists? || @command.tag_exists? || @command.merge_request_ref_exists?
                  return error('Reference not found')
                end
              end

              unless @command.sha
                return error('Commit not found')
              end

              if @command.ambiguous_ref?
                error('Ref is ambiguous')
              end
            end

            def break?
              @pipeline.errors.any?
            end
          end
        end
      end
    end
  end
end
