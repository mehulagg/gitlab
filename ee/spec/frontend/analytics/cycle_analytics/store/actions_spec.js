import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { OVERVIEW_STAGE_CONFIG } from 'ee/analytics/cycle_analytics/constants';
import * as actions from 'ee/analytics/cycle_analytics/store/actions';
import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import * as types from 'ee/analytics/cycle_analytics/store/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import { createdAfter, createdBefore, currentGroup } from 'jest/cycle_analytics/mock_data';
import createFlash from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';
import {
  allowedStages as stages,
  customizableStagesAndEvents,
  endpoints,
  valueStreams,
} from '../mock_data';

const mockStartEventIdentifier = 'issue_first_mentioned_in_commit';
const mockEndEventIdentifier = 'issue_first_added_to_board';
const mockEvents = {
  startEventIdentifier: mockStartEventIdentifier,
  endEventIdentifier: mockEndEventIdentifier,
};

const group = { fullPath: 'fake_group_full_path' };
const milestonesPath = 'fake_milestones_path';
const labelsPath = 'fake_labels_path';

const stageData = { events: [] };
const error = new Error(`Request failed with status code ${httpStatusCodes.NOT_FOUND}`);
const flashErrorMessage = 'There was an error while fetching value stream analytics data.';

stages[0].hidden = true;
const activeStages = stages.filter(({ hidden }) => !hidden);
const hiddenStage = stages[0];

const [selectedStage] = activeStages;
const selectedStageSlug = selectedStage.slug;
const [selectedValueStream] = valueStreams;

const mockGetters = {
  currentGroupPath: () => currentGroup.fullPath,
  currentValueStreamId: () => selectedValueStream.id,
};

jest.mock('~/flash');

describe('Value Stream Analytics actions', () => {
  let state;
  let mock;

  beforeEach(() => {
    state = {
      createdAfter,
      createdBefore,
      stages: [],
      featureFlags: {},
      activeStages,
      selectedValueStream,
      ...mockGetters,
    };
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    mock.restore();
    state = { ...state, currentGroup: null };
  });

  it.each`
    action                   | type                       | stateKey                | payload
    ${'setFeatureFlags'}     | ${'SET_FEATURE_FLAGS'}     | ${'featureFlags'}       | ${{ someFeatureFlag: true }}
    ${'setSelectedProjects'} | ${'SET_SELECTED_PROJECTS'} | ${'selectedProjectIds'} | ${[10, 20, 30, 40]}
  `('$action should set $stateKey with $payload and type $type', ({ action, type, payload }) => {
    return testAction(
      actions[action],
      payload,
      state,
      [
        {
          type,
          payload,
        },
      ],
      [],
    );
  });

  describe('setSelectedStage', () => {
    const data = { id: 'someStageId' };

    it(`dispatches the ${types.SET_SELECTED_STAGE} and ${types.SET_PAGINATION} actions`, () => {
      return testAction(actions.setSelectedStage, data, { ...state, selectedValueStream: {} }, [
        { type: types.SET_SELECTED_STAGE, payload: data },
      ]);
    });
  });

  describe('setSelectedValueStream', () => {
    const vs = { id: 'vs-1', name: 'Value stream 1' };

    it('refetches the Value Stream Analytics data', () => {
      return testAction(
        actions.setSelectedValueStream,
        vs,
        { ...state, selectedValueStream: {} },
        [{ type: types.SET_SELECTED_VALUE_STREAM, payload: vs }],
        [{ type: 'fetchValueStreamData' }],
      );
    });
  });

  describe('setPaths', () => {
    it('dispatches the filters/setEndpoints action with enpoints', () => {
      return testAction(
        actions.setPaths,
        { groupPath: group.fullPath, milestonesPath, labelsPath },
        state,
        [],
        [
          {
            type: 'filters/setEndpoints',
            payload: {
              groupEndpoint: 'fake_group_full_path',
              labelsEndpoint: 'fake_labels_path.json',
              milestonesEndpoint: 'fake_milestones_path.json',
            },
          },
        ],
      );
    });
  });

  describe('fetchStageData', () => {
    const headers = {
      'X-Next-Page': 2,
      'X-Page': 1,
    };

    beforeEach(() => {
      state = { ...state, currentGroup };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.stageData).reply(httpStatusCodes.OK, stageData, headers);
    });

    it(`commits ${types.RECEIVE_STAGE_DATA_SUCCESS} with received data and headers on success`, () => {
      return testAction(
        actions.fetchStageData,
        selectedStageSlug,
        state,
        [
          {
            type: types.RECEIVE_STAGE_DATA_SUCCESS,
            payload: stageData,
          },
          {
            type: types.SET_PAGINATION,
            payload: { page: headers['X-Page'], hasNextPage: true },
          },
        ],
        [{ type: 'requestStageData' }],
      );
    });

    describe('without a next page', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock
          .onGet(endpoints.stageData)
          .reply(httpStatusCodes.OK, { events: [] }, { ...headers, 'X-Next-Page': null });
      });

      it('sets hasNextPage to false', () => {
        return testAction(
          actions.fetchStageData,
          selectedStageSlug,
          state,
          [
            {
              type: types.RECEIVE_STAGE_DATA_SUCCESS,
              payload: { events: [] },
            },
            {
              type: types.SET_PAGINATION,
              payload: { page: headers['X-Page'], hasNextPage: false },
            },
          ],
          [{ type: 'requestStageData' }],
        );
      });
    });

    describe('with a failing request', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onGet(endpoints.stageData).replyOnce(httpStatusCodes.NOT_FOUND, { error });
      });

      it('dispatches receiveStageDataError on error', () => {
        return testAction(
          actions.fetchStageData,
          selectedStage,
          state,
          [],
          [
            {
              type: 'requestStageData',
            },
            {
              type: 'receiveStageDataError',
              payload: error,
            },
          ],
        );
      });
    });
  });

  describe('receiveStageDataError', () => {
    const message = 'fake error';

    it(`commits the ${types.RECEIVE_STAGE_DATA_ERROR} mutation`, () => {
      return testAction(
        actions.receiveStageDataError,
        { message },
        state,
        [
          {
            type: types.RECEIVE_STAGE_DATA_ERROR,
            payload: message,
          },
        ],
        [],
      );
    });

    it('will flash an error message', () => {
      actions.receiveStageDataError({ commit: () => {} }, {});
      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching data for the selected stage',
      });
    });
  });

  describe('fetchCycleAnalyticsData', () => {
    function mockFetchCycleAnalyticsAction(overrides = {}) {
      const mocks = {
        requestCycleAnalyticsData:
          overrides.requestCycleAnalyticsData || jest.fn().mockResolvedValue(),
        fetchStageMedianValues: overrides.fetchStageMedianValues || jest.fn().mockResolvedValue(),
        fetchGroupStagesAndEvents:
          overrides.fetchGroupStagesAndEvents || jest.fn().mockResolvedValue(),
        receiveCycleAnalyticsDataSuccess:
          overrides.receiveCycleAnalyticsDataSuccess || jest.fn().mockResolvedValue(),
      };
      return {
        mocks,
        mockDispatchContext: jest
          .fn()
          .mockImplementationOnce(mocks.requestCycleAnalyticsData)
          .mockImplementationOnce(mocks.fetchGroupStagesAndEvents)
          .mockImplementationOnce(mocks.fetchStageMedianValues)
          .mockImplementationOnce(mocks.receiveCycleAnalyticsDataSuccess),
      };
    }

    beforeEach(() => {
      state = { ...state, currentGroup, createdAfter, createdBefore };
    });

    it(`dispatches actions for required value stream analytics analytics data`, () => {
      return testAction(
        actions.fetchCycleAnalyticsData,
        state,
        null,
        [],
        [
          { type: 'requestCycleAnalyticsData' },
          { type: 'fetchValueStreams' },
          { type: 'receiveCycleAnalyticsDataSuccess' },
        ],
      );
    });

    it(`displays an error if fetchStageMedianValues fails`, () => {
      const { mockDispatchContext } = mockFetchCycleAnalyticsAction({
        fetchStageMedianValues: actions.fetchStageMedianValues({
          dispatch: jest
            .fn()
            .mockResolvedValueOnce()
            .mockImplementation(actions.receiveStageMedianValuesError({ commit: () => {} })),
          commit: () => {},
          state: { ...state },
          getters: {
            ...getters,
            activeStages,
          },
        }),
      });

      return actions
        .fetchCycleAnalyticsData({
          dispatch: mockDispatchContext,
          state: {},
          commit: () => {},
        })
        .then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'There was an error fetching median data for stages',
          });
        });
    });

    it(`displays an error if fetchGroupStagesAndEvents fails`, () => {
      const { mockDispatchContext } = mockFetchCycleAnalyticsAction({
        fetchGroupStagesAndEvents: actions.fetchGroupStagesAndEvents({
          dispatch: jest
            .fn()
            .mockResolvedValueOnce()
            .mockImplementation(actions.receiveGroupStagesError({ commit: () => {} })),
          commit: () => {},
          state: { ...state },
          getters,
        }),
      });

      return actions
        .fetchCycleAnalyticsData({
          dispatch: mockDispatchContext,
          state: {},
          commit: () => {},
        })
        .then(() => {
          expect(createFlash).toHaveBeenCalledWith({
            message: 'There was an error fetching value stream analytics stages.',
          });
        });
    });
  });

  describe('receiveCycleAnalyticsDataError', () => {
    it(`commits the ${types.RECEIVE_VALUE_STREAM_DATA_ERROR} mutation on a 403 response`, () => {
      const response = { status: 403 };
      return testAction(
        actions.receiveCycleAnalyticsDataError,
        { response },
        state,
        [
          {
            type: types.RECEIVE_VALUE_STREAM_DATA_ERROR,
            payload: response.status,
          },
        ],
        [],
      );
    });

    it(`commits the ${types.RECEIVE_VALUE_STREAM_DATA_ERROR} mutation on a non 403 error response`, () => {
      const response = { status: 500 };
      return testAction(
        actions.receiveCycleAnalyticsDataError,
        { response },
        state,
        [
          {
            type: types.RECEIVE_VALUE_STREAM_DATA_ERROR,
            payload: response.status,
          },
        ],
        [],
      );
    });

    it('will flash an error when the response is not 403', () => {
      const response = { status: 500 };
      actions.receiveCycleAnalyticsDataError(
        {
          commit: () => {},
        },
        { response },
      );

      expect(createFlash).toHaveBeenCalledWith({ message: flashErrorMessage });
    });
  });

  describe('receiveGroupStagesSuccess', () => {
    it(`commits the ${types.RECEIVE_GROUP_STAGES_SUCCESS} mutation'`, () => {
      return testAction(
        actions.receiveGroupStagesSuccess,
        { ...customizableStagesAndEvents.stages },
        state,
        [
          {
            type: types.RECEIVE_GROUP_STAGES_SUCCESS,
            payload: { ...customizableStagesAndEvents.stages },
          },
        ],
        [],
      );
    });
  });

  describe('setDefaultSelectedStage', () => {
    it("dispatches the 'setSelectedStage' with the overview stage", () => {
      return testAction(
        actions.setDefaultSelectedStage,
        null,
        state,
        [],
        [{ type: 'setSelectedStage', payload: OVERVIEW_STAGE_CONFIG }],
      );
    });
  });

  describe('fetchStageMedianValues', () => {
    let mockDispatch = jest.fn();
    const fetchMedianResponse = activeStages.map(({ slug: id }) => ({ events: [], id }));

    beforeEach(() => {
      state = { ...state, stages, currentGroup };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.stageMedian).reply(httpStatusCodes.OK, { events: [] });
      mockDispatch = jest.fn();
    });

    it('dispatches receiveStageMedianValuesSuccess with received data on success', () => {
      return testAction(
        actions.fetchStageMedianValues,
        null,
        state,
        [{ type: types.RECEIVE_STAGE_MEDIANS_SUCCESS, payload: fetchMedianResponse }],
        [{ type: 'requestStageMedianValues' }],
      );
    });

    it('does not request hidden stages', () => {
      return actions
        .fetchStageMedianValues({
          state,
          getters: {
            ...getters,
            activeStages,
          },
          commit: () => {},
          dispatch: mockDispatch,
        })
        .then(() => {
          expect(mockDispatch).not.toHaveBeenCalledWith('receiveStageMedianValuesSuccess', {
            events: [],
            id: hiddenStage.id,
          });
        });
    });

    describe(`Status ${httpStatusCodes.OK} and error message in response`, () => {
      const dataError = 'Too much data';
      const payload = activeStages.map(({ slug: id }) => ({ value: null, id, error: dataError }));

      beforeEach(() => {
        mock.onGet(endpoints.stageMedian).reply(httpStatusCodes.OK, { error: dataError });
      });

      it(`dispatches the 'RECEIVE_STAGE_MEDIANS_SUCCESS' with ${dataError}`, () => {
        return testAction(
          actions.fetchStageMedianValues,
          null,
          state,
          [{ type: types.RECEIVE_STAGE_MEDIANS_SUCCESS, payload }],
          [{ type: 'requestStageMedianValues' }],
        );
      });
    });

    describe('with a failing request', () => {
      beforeEach(() => {
        mock.onGet(endpoints.stageMedian).reply(httpStatusCodes.NOT_FOUND, { error });
      });

      it('will dispatch receiveStageMedianValuesError', () => {
        return testAction(
          actions.fetchStageMedianValues,
          null,
          state,
          [],
          [
            { type: 'requestStageMedianValues' },
            { type: 'receiveStageMedianValuesError', payload: error },
          ],
        );
      });
    });
  });

  describe('receiveStageMedianValuesError', () => {
    it(`commits the ${types.RECEIVE_STAGE_MEDIANS_ERROR} mutation`, () =>
      testAction(
        actions.receiveStageMedianValuesError,
        {},
        state,
        [
          {
            type: types.RECEIVE_STAGE_MEDIANS_ERROR,
            payload: {},
          },
        ],
        [],
      ));

    it('will flash an error message', () => {
      actions.receiveStageMedianValuesError({ commit: () => {} });
      expect(createFlash).toHaveBeenCalledWith({
        message: 'There was an error fetching median data for stages',
      });
    });
  });

  describe('fetchStageCountValues', () => {
    const fetchCountResponse = activeStages.map(({ slug: id }) => ({ events: [], id }));

    beforeEach(() => {
      state = {
        ...state,
        stages,
        currentGroup,
        featureFlags: state.featureFlags,
      };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.stageCount).reply(httpStatusCodes.OK, { events: [] });
    });

    it('dispatches receiveStageCountValuesSuccess with received data on success', () => {
      return testAction(
        actions.fetchStageCountValues,
        null,
        state,
        [
          { type: types.REQUEST_STAGE_COUNTS },
          { type: types.RECEIVE_STAGE_COUNTS_SUCCESS, payload: fetchCountResponse },
        ],
        [],
      );
    });
  });

  describe('initializeCycleAnalytics', () => {
    let mockDispatch;
    let mockCommit;
    let store;

    const selectedAuthor = 'Noam Chomsky';
    const selectedMilestone = '13.6';
    const selectedAssigneeList = ['nchom'];
    const selectedLabelList = ['label 1', 'label 2'];
    const initialData = {
      group: currentGroup,
      projectIds: [1, 2],
      milestonesPath,
      labelsPath,
      selectedAuthor,
      selectedMilestone,
      selectedAssigneeList,
      selectedLabelList,
    };

    beforeEach(() => {
      mockDispatch = jest.fn(() => Promise.resolve());
      mockCommit = jest.fn();
      store = {
        state,
        getters,
        commit: mockCommit,
        dispatch: mockDispatch,
      };
    });

    describe('with only group in initialData', () => {
      it('commits "INITIALIZE_VSA"', async () => {
        await actions.initializeCycleAnalytics(store, { group });
        expect(mockCommit).toHaveBeenCalledWith('INITIALIZE_VSA', { group });
      });

      it('dispatches "fetchCycleAnalyticsData" and "initializeCycleAnalyticsSuccess"', async () => {
        await actions.initializeCycleAnalytics(store, { group });
        expect(mockDispatch).toHaveBeenCalledWith('fetchCycleAnalyticsData');
      });
    });

    describe('with initialData', () => {
      it.each`
        action                        | args
        ${'setPaths'}                 | ${{ milestonesPath, labelsPath, groupPath: currentGroup.fullPath }}
        ${'filters/initialize'}       | ${{ selectedAuthor, selectedMilestone, selectedAssigneeList, selectedLabelList }}
        ${'durationChart/setLoading'} | ${true}
        ${'typeOfWork/setLoading'}    | ${true}
      `('dispatches $action', async ({ action, args }) => {
        await actions.initializeCycleAnalytics(store, initialData);
        expect(mockDispatch).toHaveBeenCalledWith(action, args);
      });

      it('dispatches "fetchCycleAnalyticsData" and "initializeCycleAnalyticsSuccess"', async () => {
        await actions.initializeCycleAnalytics(store, initialData);
        expect(mockDispatch).toHaveBeenCalledWith('fetchCycleAnalyticsData');
        expect(mockDispatch).toHaveBeenCalledWith('initializeCycleAnalyticsSuccess');
      });

      describe('with a selected stage', () => {
        it('dispatches "setSelectedStage" and "fetchStageData"', async () => {
          const stage = { id: 2, title: 'plan' };
          await actions.initializeCycleAnalytics(store, {
            ...initialData,
            stage,
          });
          expect(mockDispatch).toHaveBeenCalledWith('setSelectedStage', stage);
          expect(mockDispatch).toHaveBeenCalledWith('fetchStageData', stage.id);
        });
      });

      describe('with pagination parameters', () => {
        it('dispatches "setSelectedStage" and "fetchStageData"', async () => {
          const stage = { id: 2, title: 'plan' };
          const pagination = { sort: 'end_event', direction: 'desc', page: 1337 };
          const payload = { ...initialData, stage, pagination };
          await actions.initializeCycleAnalytics(store, payload);
          expect(mockCommit).toHaveBeenCalledWith('INITIALIZE_VSA', payload);
        });
      });

      describe('without a selected stage', () => {
        it('dispatches "setDefaultSelectedStage"', async () => {
          await actions.initializeCycleAnalytics(store, {
            ...initialData,
            stage: null,
          });
          expect(mockDispatch).not.toHaveBeenCalledWith('setSelectedStage');
          expect(mockDispatch).not.toHaveBeenCalledWith('fetchStageData');
          expect(mockDispatch).toHaveBeenCalledWith('setDefaultSelectedStage');
        });
      });

      it('commits "INITIALIZE_VSA"', async () => {
        await actions.initializeCycleAnalytics(store, initialData);
        expect(mockCommit).toHaveBeenCalledWith('INITIALIZE_VSA', initialData);
      });
    });
  });

  describe('initializeCycleAnalyticsSuccess', () => {
    it(`commits the ${types.INITIALIZE_VALUE_STREAM_SUCCESS} mutation`, () =>
      testAction(
        actions.initializeCycleAnalyticsSuccess,
        null,
        state,
        [{ type: types.INITIALIZE_VALUE_STREAM_SUCCESS }],
        [],
      ));
  });

  describe('createValueStream', () => {
    const payload = {
      name: 'cool value stream',
      stages: [
        {
          ...selectedStage,
          ...mockEvents,
          id: null,
        },
        { ...hiddenStage, ...mockEvents },
      ],
    };

    const createResp = { id: 'new value stream', is_custom: true, ...payload };

    beforeEach(() => {
      state = { currentGroup };
    });

    describe('with no errors', () => {
      beforeEach(() => {
        mock.onPost(endpoints.valueStreamData).replyOnce(httpStatusCodes.OK, createResp);
      });

      it(`commits the ${types.REQUEST_CREATE_VALUE_STREAM} and ${types.RECEIVE_CREATE_VALUE_STREAM_SUCCESS} actions`, () => {
        return testAction(
          actions.createValueStream,
          payload,
          state,
          [
            {
              type: types.REQUEST_CREATE_VALUE_STREAM,
            },
          ],
          [{ type: 'receiveCreateValueStreamSuccess', payload: createResp }],
        );
      });
    });

    describe('with errors', () => {
      const errors = { name: ['is taken'] };
      const message = { message: 'error' };
      const resp = { message, payload: { errors } };
      beforeEach(() => {
        mock.onPost(endpoints.valueStreamData).replyOnce(httpStatusCodes.NOT_FOUND, resp);
      });

      it(`commits the ${types.REQUEST_CREATE_VALUE_STREAM} and ${types.RECEIVE_CREATE_VALUE_STREAM_ERROR} actions `, () => {
        return testAction(
          actions.createValueStream,
          payload,
          state,
          [
            { type: types.REQUEST_CREATE_VALUE_STREAM },
            {
              type: types.RECEIVE_CREATE_VALUE_STREAM_ERROR,
              payload: { message, data: payload, errors },
            },
          ],
          [],
        );
      });
    });
  });

  describe('updateValueStream', () => {
    const payload = {
      name: 'cool value stream',
      stages: [
        {
          ...selectedStage,
          ...mockEvents,
          id: 'stage-1',
        },
        { ...hiddenStage, ...mockEvents },
      ],
    };
    const updateResp = { id: 'new value stream', is_custom: true, ...payload };

    beforeEach(() => {
      state = { currentGroup };
    });

    describe('with no errors', () => {
      beforeEach(() => {
        mock.onPut(endpoints.valueStreamData).replyOnce(httpStatusCodes.OK, updateResp);
      });

      it(`commits the ${types.REQUEST_UPDATE_VALUE_STREAM} and ${types.RECEIVE_UPDATE_VALUE_STREAM_SUCCESS} actions`, () => {
        return testAction(
          actions.updateValueStream,
          payload,
          state,
          [
            { type: types.REQUEST_UPDATE_VALUE_STREAM },
            { type: types.RECEIVE_UPDATE_VALUE_STREAM_SUCCESS, payload: updateResp },
          ],
          [{ type: 'fetchCycleAnalyticsData' }],
        );
      });
    });

    describe('with errors', () => {
      const errors = { name: ['is taken'] };
      const message = { message: 'error' };
      const resp = { message, payload: { errors } };
      beforeEach(() => {
        mock.onPut(endpoints.valueStreamData).replyOnce(httpStatusCodes.NOT_FOUND, resp);
      });

      it(`commits the ${types.REQUEST_UPDATE_VALUE_STREAM} and ${types.RECEIVE_UPDATE_VALUE_STREAM_ERROR} actions `, () => {
        return testAction(actions.updateValueStream, payload, state, [
          { type: types.REQUEST_UPDATE_VALUE_STREAM },
          {
            type: types.RECEIVE_UPDATE_VALUE_STREAM_ERROR,
            payload: { message, data: payload, errors },
          },
        ]);
      });
    });
  });

  describe('deleteValueStream', () => {
    const payload = 'my-fake-value-stream';

    beforeEach(() => {
      state = { currentGroup };
    });

    describe('with no errors', () => {
      beforeEach(() => {
        mock.onDelete(endpoints.valueStreamData).replyOnce(httpStatusCodes.OK, {});
      });

      it(`commits the ${types.REQUEST_DELETE_VALUE_STREAM} and ${types.RECEIVE_DELETE_VALUE_STREAM_SUCCESS} actions`, () => {
        return testAction(
          actions.deleteValueStream,
          payload,
          state,
          [
            {
              type: types.REQUEST_DELETE_VALUE_STREAM,
            },
            {
              type: types.RECEIVE_DELETE_VALUE_STREAM_SUCCESS,
            },
          ],
          [{ type: 'fetchCycleAnalyticsData' }],
        );
      });
    });

    describe('with errors', () => {
      const message = { message: 'failed to delete the value stream' };
      const resp = { message };
      beforeEach(() => {
        mock.onDelete(endpoints.valueStreamData).replyOnce(httpStatusCodes.NOT_FOUND, resp);
      });

      it(`commits the ${types.REQUEST_DELETE_VALUE_STREAM} and ${types.RECEIVE_DELETE_VALUE_STREAM_ERROR} actions `, () => {
        return testAction(
          actions.deleteValueStream,
          payload,
          state,
          [
            { type: types.REQUEST_DELETE_VALUE_STREAM },
            {
              type: types.RECEIVE_DELETE_VALUE_STREAM_ERROR,
              payload: message,
            },
          ],
          [],
        );
      });
    });
  });

  describe('fetchValueStreams', () => {
    beforeEach(() => {
      state = {
        ...state,
        stages: [{ slug: selectedStageSlug }],
        currentGroup,
        featureFlags: {
          ...state.featureFlags,
        },
      };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.valueStreamData).reply(httpStatusCodes.OK, { stages: [], events: [] });
    });

    it(`commits ${types.REQUEST_VALUE_STREAMS} and dispatches receiveValueStreamsSuccess with received data on success`, () => {
      return testAction(
        actions.fetchValueStreams,
        null,
        state,
        [{ type: types.REQUEST_VALUE_STREAMS }],
        [
          {
            payload: {
              events: [],
              stages: [],
            },
            type: 'receiveValueStreamsSuccess',
          },
        ],
      );
    });

    describe('with a failing request', () => {
      let mockCommit;
      beforeEach(() => {
        mockCommit = jest.fn();
        mock.onGet(endpoints.valueStreamData).reply(httpStatusCodes.NOT_FOUND);
      });

      it(`will commit ${types.RECEIVE_VALUE_STREAMS_ERROR}`, () => {
        return actions.fetchValueStreams({ state, getters, commit: mockCommit }).catch(() => {
          expect(mockCommit.mock.calls).toEqual([
            ['REQUEST_VALUE_STREAMS'],
            ['RECEIVE_VALUE_STREAMS_ERROR', httpStatusCodes.NOT_FOUND],
          ]);
        });
      });

      it(`throws an error`, () => {
        return expect(
          actions.fetchValueStreams({ state, getters, commit: mockCommit }),
        ).rejects.toThrow('Request failed with status code 404');
      });
    });

    describe('receiveValueStreamsSuccess', () => {
      it(`with a selectedValueStream in state commits the ${types.RECEIVE_VALUE_STREAMS_SUCCESS} mutation and dispatches 'fetchValueStreamData' and 'fetchStageCountValues'`, () => {
        return testAction(
          actions.receiveValueStreamsSuccess,
          valueStreams,
          state,
          [
            {
              type: types.RECEIVE_VALUE_STREAMS_SUCCESS,
              payload: valueStreams,
            },
          ],
          [{ type: 'fetchValueStreamData' }, { type: 'fetchStageCountValues' }],
        );
      });

      it(`commits the ${types.RECEIVE_VALUE_STREAMS_SUCCESS} mutation and dispatches 'setSelectedValueStream' and 'fetchStageCountValues'`, () => {
        return testAction(
          actions.receiveValueStreamsSuccess,
          valueStreams,
          {
            ...state,
            selectedValueStream: null,
          },
          [
            {
              type: types.RECEIVE_VALUE_STREAMS_SUCCESS,
              payload: valueStreams,
            },
          ],
          [
            { type: 'setSelectedValueStream', payload: selectedValueStream },
            { type: 'fetchStageCountValues' },
          ],
        );
      });
    });
  });

  describe('fetchValueStreamData', () => {
    beforeEach(() => {
      state = {
        ...state,
        stages: [{ slug: selectedStageSlug }],
        currentGroup,
        featureFlags: {
          ...state.featureFlags,
        },
      };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.valueStreamData).reply(httpStatusCodes.OK, { stages: [], events: [] });
    });

    it('dispatches fetchGroupStagesAndEvents, fetchStageMedianValues and durationChart/fetchDurationData', () => {
      return testAction(
        actions.fetchValueStreamData,
        null,
        state,
        [],
        [
          { type: 'fetchGroupStagesAndEvents' },
          { type: 'fetchStageMedianValues' },
          { type: 'durationChart/fetchDurationData' },
        ],
      );
    });
  });

  describe.each`
    targetAction            | payload                            | mutations
    ${actions.setDateRange} | ${{ createdAfter, createdBefore }} | ${[{ type: 'SET_DATE_RANGE', payload: { createdAfter, createdBefore } }]}
    ${actions.setFilters}   | ${''}                              | ${[]}
  `('$action', ({ targetAction, payload, mutations }) => {
    let stateWithOverview = null;

    beforeEach(() => {
      stateWithOverview = { ...state, isOverviewStageSelected: () => true };
    });

    it('dispatches the fetchCycleAnalyticsData action', () => {
      return testAction(targetAction, payload, stateWithOverview, mutations, [
        { type: 'fetchCycleAnalyticsData' },
      ]);
    });

    describe('with a stage selected', () => {
      beforeEach(() => {
        stateWithOverview = { ...state, selectedStage };
      });

      it('dispatches the fetchStageData action', () => {
        return testAction(targetAction, payload, stateWithOverview, mutations, [
          { type: 'fetchStageData', payload: selectedStage.id },
          { type: 'fetchCycleAnalyticsData' },
        ]);
      });
    });
  });
});
