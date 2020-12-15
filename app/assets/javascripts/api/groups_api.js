import axios from '../lib/utils/axios_utils';
import { buildApiUrl } from './api_utils';

const DEFAULT_PER_PAGE = 20;
const GROUPS_PATH = '/api/:version/groups.json';

export function getGroups(query, options, callback = () => {}) {
  const url = buildApiUrl(GROUPS_PATH);
  return axios
    .get(url, {
      params: {
        search: query,
        per_page: DEFAULT_PER_PAGE,
        ...options,
      },
    })
    .then(({ data }) => {
      callback(data);

      return data;
    });
}
