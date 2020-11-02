import axios from 'axios';
import Api from '~/api';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

export const issueMetricImagesPath = '/api/:version/projects/:id/issues/:issue_iid/metric_images';

export const getMetricImages = async ({ issueIid, id }) => {
  const metricImagesUrl = Api.buildUrl(issueMetricImagesPath)
    .replace(':id', encodeURIComponent(id))
    .replace(':issue_iid', encodeURIComponent(issueIid));

  const response = await axios.get(metricImagesUrl);
  return convertObjectPropsToCamelCase(response.data, { deep: true });
};

export const uploadMetricImage = async ({ issueIid, id, file, url = null }) => {
  const options = { headers: { 'Content-Type': 'multipart/form-data' } };
  const metricImagesUrl = Api.buildUrl(issueMetricImagesPath)
    .replace(':id', encodeURIComponent(id))
    .replace(':issue_iid', encodeURIComponent(issueIid));

  const formData = new FormData();

  formData.append('file', file);

  if (url) {
    formData.append('url', url);
  }

  const response = await axios.post(metricImagesUrl, formData, options);
  return convertObjectPropsToCamelCase(response.data);
};
