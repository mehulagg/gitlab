import axios from '../lib/utils/axios_utils';
import { buildApiUrl } from './api_utils';
import { DEFAULT_PER_PAGE } from './constants';

const PROJECTS_PATH = '/api/:version/projects.json';
const RAW_FILE_PATH = '/api/:version/projects/:id/repository/files/:path/raw';

export function getProjects(query, options, callback = () => {}) {
  const url = buildApiUrl(PROJECTS_PATH);
  const defaults = {
    search: query,
    per_page: DEFAULT_PER_PAGE,
    simple: true,
  };

  if (gon.current_user_id) {
    defaults.membership = true;
  }

  return axios
    .get(url, {
      params: Object.assign(defaults, options),
    })
    .then(({ data, headers }) => {
      callback(data);
      return { data, headers };
    });
}

export function getRawFile(id, path, params = { ref: 'master' }) {
  const url = buildApiUrl(RAW_FILE_PATH)
    .replace(':id', encodeURIComponent(id))
    .replace(':path', encodeURIComponent(path));

  return axios.get(url, { params });
}
