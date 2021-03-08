import axios from './axios_utils';
import { normalizeHeaders } from './common_utils';

// This is used in the select2 config to replace jQuery.ajax with axios
export const select2AxiosTransport = (params, success, failure) => {
  return axios[params.type.toLowerCase()](params.url, {
    params: params.data,
  })
    .then((res) => {
      const results = res.data || [];
      const headers = normalizeHeaders(res.headers);
      const currentPage = parseInt(headers['X-PAGE'], 10) || 0;
      const totalPages = parseInt(headers['X-TOTAL-PAGES'], 10) || 0;
      const more = currentPage < totalPages;

      success({
        results,
        pagination: {
          more,
        },
      });
    })
    .catch(failure);
}
