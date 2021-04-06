import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

const GROUPS_BILLABLE_MEMBERS_SINGLE_PATH = '/api/:version/groups/:group_id/billable_members/:id';

export function removeBillableMemberFromGroup(groupId, memberId, options) {
  const url = buildApiUrl(GROUPS_BILLABLE_MEMBERS_SINGLE_PATH)
    .replace(':group_id', groupId)
    .replace(':id', memberId);

  return axios.delete(url, { params: { ...options } });
}
