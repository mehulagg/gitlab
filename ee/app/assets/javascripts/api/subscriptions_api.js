import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

const SUBSCRIPTIONS_PATH = '/api/:version/subscriptions';

export function createSubscription(groupId, customer, subscription) {
  const url = buildApiUrl(SUBSCRIPTIONS_PATH);
  const params = {
    selectedGroup: groupId,
    customer,
    subscription,
  };

  return axios.post(url, { params });
}
