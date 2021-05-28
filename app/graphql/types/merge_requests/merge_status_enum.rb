# frozen_string_literal: true

module Types
  module MergeRequests
    class MergeStatusEnum < BaseEnum
      graphql_name 'MergeStatus'
      description 'Representation of whether a GitLab merge request be merged.'

      value 'UNCHECKED',
            value: 'unchecked',
            description: 'Merge status has not been checked.'
      value 'CHECKING',
            value: 'checking',
            description: 'Currently checking for mergeability.'
      value 'CAN_BE_MERGED',
            value: 'can_be_merged',
            description: 'There are no conflicts between the source and target branches.'
      value 'CANNOT_BE_MERGED',
            value: 'cannot_be_merged',
            description: 'There are conflicts between the source and target branches.'
      value 'CANNOT_BE_MERGED_RECHECK',
            value: 'cannot_be_merged_recheck',
            description: 'Currently unchecked. The previous state was cannot be merged.'
    end
  end
end
