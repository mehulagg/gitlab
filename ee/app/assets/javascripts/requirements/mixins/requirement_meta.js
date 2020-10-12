import { __, sprintf } from '~/locale';
import { getTimeago } from '~/lib/utils/datetime_utility';

import { FilterState } from '../constants';

export default {
  computed: {
    reference() {
      return `REQ-${this.requirement.iid}`;
    },
    titleHtml() {
      return this.requirement?.titleHtml;
    },
    descriptionHtml() {
      return this.requirement?.descriptionHtml;
    },
    isArchived() {
      return this.requirement?.state === FilterState.archived;
    },
    author() {
      return this.requirement?.author;
    },
    createdAt() {
      return sprintf(__('created %{timeAgo}'), {
        timeAgo: getTimeago().format(this.requirement.createdAt),
      });
    },
    updatedAt() {
      return sprintf(__('updated %{timeAgo}'), {
        timeAgo: getTimeago().format(this.requirement.updatedAt),
      });
    },
    testReport() {
      // return this.requirement.testReports.nodes[0];
      return {
        id: 'gid://gitlab/RequirementsManagement::TestReport/1',
        state: 'PASSED',
        createdAt: '2020-06-04T10:55:48Z',
        __typename: 'TestReport',
      };
    },
    canUpdate() {
      return this.requirement?.userPermissions.updateRequirement;
    },
    canArchive() {
      return this.requirement?.userPermissions.adminRequirement;
    },
  },
};
