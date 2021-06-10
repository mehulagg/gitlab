import MockAdapter from 'axios-mock-adapter';

import * as actions from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/actions';
import * as types from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/mutation_types';
import getInitialState from 'ee/threat_monitoring/store/modules/threat_monitoring_statistics/state';
import testAction from 'helpers/vuex_action_helper';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';

import { mockNetworkPolicyStatisticsResponse } from '../../../mocks/mock_data';

jest.mock('~/flash');

const statisticsEndpoint = 'statisticsEndpoint';
const timeRange = {
  from: '2019-01-30T16:00:00.000Z',
  to: '2019-01-31T00:00:00.000Z',
};

describe('threatMonitoringStatistics actions', () => {
  let state;

  beforeEach(() => {
    state = getInitialState();
  });

  afterEach(() => {
    createFlash.mockClear();
  });

  describe('requestStatistics', () => {
    const payload = { foo: true };

    it('commits the REQUEST_STATISTICS mutation and passes on the payload', () =>
      testAction(
        actions.requestStatistics,
        payload,
        state,
        [
          {
            type: types.REQUEST_STATISTICS,
            payload,
          },
        ],
        [],
      ));
  });

  describe('receiveStatisticsSuccess', () => {
    it('commits the RECEIVE_STATISTICS_SUCCESS mutation', () =>
      testAction(
        actions.receiveStatisticsSuccess,
        mockNetworkPolicyStatisticsResponse,
        state,
        [
          {
            type: types.RECEIVE_STATISTICS_SUCCESS,
            payload: mockNetworkPolicyStatisticsResponse,
          },
        ],
        [],
      ));
  });

  describe('receiveStatisticsError', () => {
    it('commits the RECEIVE_STATISTICS_ERROR mutation', () =>
      testAction(
        actions.receiveStatisticsError,
        undefined,
        state,
        [
          {
            type: types.RECEIVE_STATISTICS_ERROR,
          },
        ],
        [],
      ).then(() => {
        expect(createFlash).toHaveBeenCalled();
      }));
  });

  describe('fetchStatistics', () => {
    let mock;
    const currentEnvironmentId = 3;

    beforeEach(() => {
      state.statisticsEndpoint = statisticsEndpoint;
      state.threatMonitoring = { currentEnvironmentId };
      jest.spyOn(global.Date, 'now').mockImplementation(() => new Date(2019, 0, 31).getTime());
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.restore();
    });

    describe('on success', () => {
      beforeEach(() => {
        mock
          .onGet(statisticsEndpoint, {
            params: {
              environment_id: currentEnvironmentId,
              interval: 'hour',
              ...timeRange,
            },
          })
          .replyOnce(httpStatus.OK, mockNetworkPolicyStatisticsResponse);
      });

      it('should dispatch the request and success actions', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [
            {
              type: 'requestStatistics',
              payload: expect.objectContaining(timeRange),
            },
            {
              type: 'receiveStatisticsSuccess',
              payload: mockNetworkPolicyStatisticsResponse,
            },
          ],
        ));
    });

    describe('on NOT_FOUND', () => {
      beforeEach(() => {
        mock.onGet(statisticsEndpoint).replyOnce(httpStatus.NOT_FOUND);
      });

      it('should dispatch the request and success action with empty data', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [
            { type: 'requestStatistics', payload: expect.any(Object) },
            { type: 'receiveStatisticsSuccess', payload: null },
          ],
        ));
    });

    describe('on error', () => {
      beforeEach(() => {
        mock.onGet(statisticsEndpoint).replyOnce(500);
      });

      it('should dispatch the request and error actions', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [
            { type: 'requestStatistics', payload: expect.any(Object) },
            { type: 'receiveStatisticsError' },
          ],
        ));
    });

    describe('with an empty endpoint', () => {
      beforeEach(() => {
        state.statisticsEndpoint = '';
      });

      it('should dispatch receiveStatisticsError', () =>
        testAction(
          actions.fetchStatistics,
          undefined,
          state,
          [],
          [{ type: 'receiveStatisticsError' }],
        ));
    });
  });
});
