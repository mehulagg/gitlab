import MockAdapter from 'axios-mock-adapter';
import {
  setCodequalityEndpoint,
  clearCodequalityPoll,
  stopCodequalityPolling,
  fetchCodequality,
} from 'ee/diffs/store/actions';
import * as types from 'ee/diffs/store/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/flash');

describe('EE DiffsStoreActions', () => {
  describe('setCodequalityEndpoint', () => {
    it('should set given endpoint', (done) => {
      const endpoint = '/codequality_mr_diff.json';

      testAction(
        setCodequalityEndpoint,
        { endpoint },
        {},
        [{ type: types.SET_CODEQUALITY_ENDPOINT, payload: { endpoint } }],
        [],
        done,
      );
    });
  });

  describe('fetchCodequality', () => {
    let mock;
    const endpoint = '/codequality_mr_diff.json';

    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      stopCodequalityPolling();
      clearCodequalityPoll();
    });

    it('should commit SET_CODEQUALITY_DATA with received response and stop polling', (done) => {
      const data = {
        files: { 'app.js': [{ line: 1, description: 'Unexpected alert.', severity: 'minor' }] },
      };

      mock.onGet(endpoint).reply(200, { data });

      testAction(
        fetchCodequality,
        {},
        { endpointCodequality: endpoint },
        [{ type: types.SET_CODEQUALITY_DATA, payload: { data } }],
        [{ type: 'stopCodequalityPolling' }],
        done,
      );
    });

    it('should show flash on API error', (done) => {
      mock.onGet(endpoint).reply(400);

      testAction(fetchCodequality, {}, { endpoint }, [], [], () => {
        expect(createFlash).toHaveBeenCalledTimes(1);
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Something went wrong on our end while loading the code quality diff.',
        });
        done();
      });
    });
  });
});
