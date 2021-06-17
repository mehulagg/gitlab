import axios from '~/lib/utils/axios_utils';
import { ContentTypeMultipartFormData } from '~/lib/utils/headers';

export default class GroupsService {
  constructor(endpoint) {
    this.endpoint = endpoint;
  }

  replaceBlob(data) {
    return axios.put(this.endpoint, data, {
      headers: {
        ...ContentTypeMultipartFormData,
      },
    });
  }

  uploadBlob(data) {
    return axios.post(this.endpoint, data, {
      headers: {
        ...ContentTypeMultipartFormData,
      },
    });
  }
}
