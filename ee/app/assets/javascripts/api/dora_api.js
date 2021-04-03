import { buildApiUrl } from '~/api/api_utils';
import axios from '~/lib/utils/axios_utils';

export const DEPLOYMENT_FREQUENCY_METRIC_TYPE = 'deployment_frequency';
export const LEAD_TIME_FOR_CHANGES = 'lead_time_for_changes';
export const ALL_METRIC_TYPES = Object.freeze([
  DEPLOYMENT_FREQUENCY_METRIC_TYPE,
  LEAD_TIME_FOR_CHANGES,
]);

const PROJECTS_DORA_METRICS_PATH = '/api/:version/projects/:id/dora/metrics';

/**
 * Gets DORA 4 metrics data from a project
 * See https://docs.gitlab.com/ee/api/dora/metrics.html
 *
 * @param {String|Number} projectId The ID or path of the project
 * @param {String} metric The name of the metric to fetch. Must be one of:
 * `["deployment_frequency", "lead_time_for_changes"]`
 * @param {Object} params Any additional query parameters that should be
 * included with the request. These parameters are optional. See
 * https://docs.gitlab.com/ee/api/dora/metrics.html for a list of available options.
 *
 * @returns {Promise} A `Promise` that resolves to an array of data points.
 */
export function getProjectDoraMetrics(projectId, metric, params = {}) {
  if (!ALL_METRIC_TYPES.includes(metric)) {
    throw new Error(`Unsupported metric type provided to getProjectDoraMetrics(): "${metric}"`);
  }

  const url = buildApiUrl(PROJECTS_DORA_METRICS_PATH).replace(':id', encodeURIComponent(projectId));

  return axios.get(url, {
    params: {
      metric,
      ...params,
    },
  });
}
