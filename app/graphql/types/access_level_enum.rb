# frozen_string_literal: true

module Types
  class AccessLevelEnum < BaseEnum
    graphql_name 'AccessLevelEnum'
    description 'Access level to a resource'

    value 'NO_ACCESS', description: 'No access', value: Gitlab::Access::NO_ACCESS
    value 'MINIMAL_ACCESS', description: 'Minimal access', value: Gitlab::Access::MINIMAL_ACCESS
    value 'GUEST', description: 'Guest access', value: Gitlab::Access::GUEST
    value 'REPORTER', description: 'Reporter access', value: Gitlab::Access::REPORTER
    value 'DEVELOPER', description: 'Developer access', value: Gitlab::Access::DEVELOPER
    value 'MAINTAINER', description: 'Maintainer access', value: Gitlab::Access::MAINTAINER
    value 'OWNER', description: 'Owner access', value: Gitlab::Access::OWNER
  end
end
