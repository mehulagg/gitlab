import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';

import { addSubscription, removeSubscription } from '~/jira_connect/api';

describe('JiraConnect API', () => {
  let mock;
  let response;

  const addPath = 'addPath';
  const removePath = 'removePath';
  const namespace = 'namespace';
  const jwt = 'jwt';
  const successResponse = { success: true };

  const tokenSpy = jest.fn().mockReturnValue(jwt);

  window.AP = {
    context: {
      getToken: tokenSpy,
    },
  };

  beforeEach(() => {
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    response = null;
  });

  describe('addSubscription', () => {
    const makeRequest = () => addSubscription(addPath, namespace);

    it('returns success response', async () => {
      jest.spyOn(axios, 'post');
      mock
        .onPost(addPath, {
          jwt,
          namespace_path: namespace,
        })
        .replyOnce(httpStatus.OK, successResponse);

      response = await makeRequest();

      expect(tokenSpy).toHaveBeenCalled();
      expect(axios.post).toHaveBeenCalledWith(addPath, {
        jwt,
        namespace_path: namespace,
      });
      expect(response.data).toEqual(successResponse);
    });
  });

  describe('removeSubscription', () => {
    const makeRequest = () => removeSubscription(removePath);

    it('returns success response', async () => {
      jest.spyOn(axios, 'delete');
      mock.onDelete(removePath).replyOnce(httpStatus.OK, successResponse);

      response = await makeRequest();

      expect(tokenSpy).toHaveBeenCalled();
      expect(axios.delete).toHaveBeenCalledWith(removePath, {
        params: {
          jwt,
        },
      });
      expect(response.data).toEqual(successResponse);
    });
  });
});
