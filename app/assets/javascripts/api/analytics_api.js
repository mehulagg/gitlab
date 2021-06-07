import axios from '~/lib/utils/axios_utils';
import { buildApiUrl } from './api_utils';

const PROJECT_VSA_PATH_BASE = '/:project_path/-/analytics/value_stream_analytics/value_streams';
const PROJECT_VSA_PATH = `${PROJECT_VSA_PATH_BASE}/:value_stream_id`;

const buildProjectValueStreamPath = (projectPath, valueStreamId = null) => {
  if (valueStreamId) {
    return buildApiUrl(PROJECT_VSA_PATH)
      .replace(':project_path', projectPath)
      .replace(':value_stream_id', valueStreamId);
  }
  return buildApiUrl(PROJECT_VSA_PATH_BASE).replace(':project_path', projectPath);
};

export const getProjectValueStreams = (projectPath) => {
  const url = buildProjectValueStreamPath(projectPath);
  return axios.get(url);
};

// TODO: handle filter params?
export const getProjectValueStreamData = (projectPath, valueStreamId) => {
  const url = buildProjectValueStreamPath(projectPath, valueStreamId);
  return axios.get(url);
};
