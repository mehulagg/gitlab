import MockAdapter from 'axios-mock-adapter';

import testAction from 'helpers/vuex_action_helper';
import * as types from 'ee/logs/stores/mutation_types';
import logsPageState from 'ee/logs/stores/state';
import {
  setInitData,
  setSearch,
  showPodLogs,
  fetchEnvironments,
  fetchLogs,
} from 'ee/logs/stores/actions';
import { getTimeRange } from 'ee/logs/utils';
import { timeWindows } from 'ee/logs/constants';

import axios from '~/lib/utils/axios_utils';
import flash from '~/flash';

import {
  mockProjectPath,
  mockPodName,
  mockEnvironmentsEndpoint,
  mockEnvironments,
  mockPods,
  mockLogsResult,
  mockEnvName,
  mockSearch,
} from '../mock_data';

jest.mock('~/flash');
jest.mock('ee/logs/utils');

describe('Logs Store actions', () => {
  let state;
  let mock;

  const mockThirtyMinutesSeconds = 3600;
  const mockThirtyMinutes = {
    start: '2020-01-09T18:06:20.000Z',
    end: '2020-01-09T18:36:20.000Z',
  };

  beforeEach(() => {
    state = logsPageState();
    getTimeRange.mockReturnValue(mockThirtyMinutes);
  });

  afterEach(() => {
    flash.mockClear();
  });

  describe('setInitData', () => {
    it('should commit environment and pod name mutation', done => {
      testAction(
        setInitData,
        { environmentName: mockEnvName, podName: mockPodName },
        state,
        [
          { type: types.SET_PROJECT_ENVIRONMENT, payload: mockEnvName },
          { type: types.SET_CURRENT_POD_NAME, payload: mockPodName },
        ],
        [],
        done,
      );
    });
  });

  describe('setSearch', () => {
    it('should commit search mutation', done => {
      testAction(
        setSearch,
        mockSearch,
        state,
        [{ type: types.SET_SEARCH, payload: mockSearch }],
        [{ type: 'fetchLogs' }],
        done,
      );
    });
  });

  describe('showPodLogs', () => {
    it('should commit pod name', done => {
      testAction(
        showPodLogs,
        mockPodName,
        state,
        [{ type: types.SET_CURRENT_POD_NAME, payload: mockPodName }],
        [{ type: 'fetchLogs' }],
        done,
      );
    });
  });

  describe('fetchEnvironments', () => {
    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    it('should commit RECEIVE_ENVIRONMENTS_DATA_SUCCESS mutation on correct data', done => {
      mock.onGet(mockEnvironmentsEndpoint).replyOnce(200, { environments: mockEnvironments });
      testAction(
        fetchEnvironments,
        mockEnvironmentsEndpoint,
        state,
        [
          { type: types.REQUEST_ENVIRONMENTS_DATA },
          { type: types.RECEIVE_ENVIRONMENTS_DATA_SUCCESS, payload: mockEnvironments },
        ],
        [{ type: 'fetchLogs' }],
        done,
      );
    });

    it('should commit RECEIVE_ENVIRONMENTS_DATA_ERROR on wrong data', done => {
      mock.onGet(mockEnvironmentsEndpoint).replyOnce(500);
      testAction(
        fetchEnvironments,
        mockEnvironmentsEndpoint,
        state,
        [
          { type: types.REQUEST_ENVIRONMENTS_DATA },
          { type: types.RECEIVE_ENVIRONMENTS_DATA_ERROR },
        ],
        [],
        () => {
          expect(flash).toHaveBeenCalledTimes(1);
          done();
        },
      );
    });
  });

  describe('fetchLogs', () => {
    beforeEach(() => {
      mock = new MockAdapter(axios);
    });

    afterEach(() => {
      mock.reset();
    });

    it('should commit logs and pod data when there is pod name defined', done => {
      state.environments.options = mockEnvironments;
      state.environments.current = mockEnvName;
      state.pods.current = mockPodName;

      const endpoint = `/${mockProjectPath}/-/logs/elasticsearch.json`;

      mock
        .onGet(endpoint, {
          params: { environment_name: mockEnvName, pod_name: mockPodName, ...mockThirtyMinutes },
        })
        .reply(200, {
          pod_name: mockPodName,
          pods: mockPods,
          logs: mockLogsResult,
        });

      mock.onGet(endpoint).replyOnce(202); // mock reactive cache

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_PODS_DATA },
          { type: types.REQUEST_LOGS_DATA },
          { type: types.SET_CURRENT_POD_NAME, payload: mockPodName },
          { type: types.RECEIVE_PODS_DATA_SUCCESS, payload: mockPods },
          { type: types.RECEIVE_LOGS_DATA_SUCCESS, payload: mockLogsResult },
        ],
        [],
        () => {
          expect(getTimeRange).toHaveBeenCalledWith(mockThirtyMinutesSeconds);
          done();
        },
      );
    });

    it('should commit logs and pod data when there is pod name defined and a non-default date range', done => {
      const mockOneDaySeconds = timeWindows.oneDay.seconds;
      const mockOneDay = {
        start: '2020-01-08T18:41:39.000Z',
        end: '2020-01-09T18:41:39.000Z',
      };

      getTimeRange.mockReturnValueOnce(mockOneDay);

      state.projectPath = mockProjectPath;
      state.environments.current = mockEnvName;
      state.pods.current = mockPodName;
      state.timeWindow.current = 'oneDay';

      const endpoint = `/${mockProjectPath}/-/logs/k8s.json`;

      mock
        .onGet(endpoint, {
          params: { environment_name: mockEnvName, pod_name: mockPodName, ...mockOneDay },
        })
        .reply(200, {
          pod_name: mockPodName,
          pods: mockPods,
          enable_advanced_querying: true,
          logs: mockLogsResult,
        });

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_PODS_DATA },
          { type: types.REQUEST_LOGS_DATA },
          { type: types.ENABLE_ADVANCED_QUERYING, payload: true },
          { type: types.SET_CURRENT_POD_NAME, payload: mockPodName },
          { type: types.RECEIVE_PODS_DATA_SUCCESS, payload: mockPods },
          { type: types.RECEIVE_LOGS_DATA_SUCCESS, payload: mockLogsResult },
        ],
        [],
        () => {
          expect(getTimeRange).toHaveBeenCalledWith(mockOneDaySeconds);
          done();
        },
      );
    });

    it('should commit logs and pod data when there is pod name and search', done => {
      state.environments.options = mockEnvironments;
      state.environments.current = mockEnvName;
      state.pods.current = mockPodName;
      state.search = mockSearch;

      const endpoint = `/${mockProjectPath}/-/logs/elasticsearch.json`;

      mock
        .onGet(endpoint, {
          params: {
            environment_name: mockEnvName,
            pod_name: mockPodName,
            search: mockSearch,
            ...mockThirtyMinutes,
          },
        })
        .reply(200, {
          pod_name: mockPodName,
          pods: mockPods,
          logs: mockLogsResult,
        });

      mock.onGet(endpoint).replyOnce(202); // mock reactive cache

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_PODS_DATA },
          { type: types.REQUEST_LOGS_DATA },
          { type: types.SET_CURRENT_POD_NAME, payload: mockPodName },
          { type: types.RECEIVE_PODS_DATA_SUCCESS, payload: mockPods },
          { type: types.RECEIVE_LOGS_DATA_SUCCESS, payload: mockLogsResult },
        ],
        [],
        done,
      );
    });

    it('should commit logs and pod data when no pod name defined', done => {
      state.environments.options = mockEnvironments;
      state.environments.current = mockEnvName;

      const endpoint = `/${mockProjectPath}/-/logs/elasticsearch.json`;

      mock
        .onGet(endpoint, { params: { environment_name: mockEnvName, ...mockThirtyMinutes } })
        .reply(200, {
          pod_name: mockPodName,
          pods: mockPods,
          logs: mockLogsResult,
        });
      mock.onGet(endpoint).replyOnce(202); // mock reactive cache

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_PODS_DATA },
          { type: types.REQUEST_LOGS_DATA },
          { type: types.SET_CURRENT_POD_NAME, payload: mockPodName },
          { type: types.RECEIVE_PODS_DATA_SUCCESS, payload: mockPods },
          { type: types.RECEIVE_LOGS_DATA_SUCCESS, payload: mockLogsResult },
        ],
        [],
        done,
      );
    });

    it('should commit logs and pod errors when backend fails', done => {
      state.environments.current = mockEnvName;

      const endpoint = `/${mockProjectPath}/logs.json?environment_name=${mockEnvName}`;
      mock.onGet(endpoint).replyOnce(500);

      testAction(
        fetchLogs,
        null,
        state,
        [
          { type: types.REQUEST_PODS_DATA },
          { type: types.REQUEST_LOGS_DATA },
          { type: types.RECEIVE_PODS_DATA_ERROR },
          { type: types.RECEIVE_LOGS_DATA_ERROR },
        ],
        [],
        () => {
          expect(flash).toHaveBeenCalledTimes(1);
          done();
        },
      );
    });
  });
});
