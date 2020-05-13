import MockAdapter from 'axios-mock-adapter';
import flashError from '~/flash';
import testAction from 'helpers/vuex_action_helper';
import axios from '~/lib/utils/axios_utils';
import { apiData } from '../mock_data';
import * as types from '~/clusters_list/store/mutation_types';
import * as actions from '~/clusters_list/store/actions';

jest.mock('~/flash.js');

describe('Clusters store actions', () => {
  describe('fetchClusters', () => {
    let mock;

    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    afterEach(() => mock.restore());

    it('should commit SET_CLUSTERS_DATA with received response', done => {
      mock.onGet().reply(200, apiData);

      testAction(
        actions.fetchClusters,
        { endpoint: apiData.endpoint },
        {},
        [
          { type: types.SET_CLUSTERS_DATA, payload: apiData },
          { type: types.SET_LOADING_STATE, payload: false },
        ],
        [],
        () => done(),
      );
    });

    it('should show flash on API error', done => {
      mock.onGet().reply(400, 'Not Found');

      testAction(actions.fetchClusters, { endpoint: apiData.endpoint }, {}, [], [], () => {
        expect(flashError).toHaveBeenCalledWith(expect.stringMatching('error'));
        done();
      });
    });
  });
});
