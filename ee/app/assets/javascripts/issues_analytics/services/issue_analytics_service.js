import axios from '~/lib/utils/axios_utils';
import { mergeUrlParams } from '~/lib/utils/url_utility';

export default {
  fetchChartData(endpoint, filters) {
    return axios.get(mergeUrlParams(filters, endpoint));
  },
};
