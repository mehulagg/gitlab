import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { OVERVIEW_STAGE_CONFIG } from 'ee/analytics/cycle_analytics/constants';
import * as actions from 'ee/analytics/cycle_analytics/store/actions';
import * as getters from 'ee/analytics/cycle_analytics/store/getters';
import * as types from 'ee/analytics/cycle_analytics/store/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';
import {
  currentGroup,
  allowedStages as stages,
  startDate,
  endDate,
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

const stageEndpoint = ({ stageId }) =>
  `/groups/${currentGroup.fullPath}/-/analytics/value_stream_analytics/value_streams/${selectedValueStream.id}/stages/${stageId}`;

jest.mock('~/flash');

describe('Value Stream Analytics actions', () => {
  let state;
  let mock;

  const shouldFlashAMessage = (msg, type = null) => {
    const args = type ? [msg, type] : [msg];
    expect(createFlash).toHaveBeenCalledWith(...args);
  };

  beforeEach(() => {
    state = {
      startDate,
      endDate,
      stages: [],
      featureFlags: {
        hasDurationChart: true,
      },
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
    ${'setFeatureFlags'}     | ${'SET_FEATURE_FLAGS'}     | ${'featureFlags'}       | ${{ hasDurationChart: true }}
    ${'setSelectedProjects'} | ${'SET_SELECTED_PROJECTS'} | ${'selectedProjectIds'} | ${[10, 20, 30, 40]}
    ${'setSelectedStage'}    | ${'SET_SELECTED_STAGE'}    | ${'selectedStage'}      | ${{ id: 'someStageId' }}
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

  describe('setDateRange', () => {
    const payload = { startDate, endDate };

    it('dispatches the fetchCycleAnalyticsData action', () => {
      return testAction(
        actions.setDateRange,
        payload,
        state,
        [{ type: types.SET_DATE_RANGE, payload: { startDate, endDate } }],
        [{ type: 'fetchCycleAnalyticsData' }],
      );
    });
  });

  describe('fetchStageData', () => {
    beforeEach(() => {
      state = { ...state, currentGroup };
      mock = new MockAdapter(axios);
      mock.onGet(endpoints.stageData).reply(httpStatusCodes.OK, { events: [] });
    });

    it('dispatches receiveStageDataSuccess with received data on success', () => {
      return testAction(
        actions.fetchStageData,
        selectedStageSlug,
        state,
        [],
        [
          { type: 'requestStageData' },
          {
            type: 'receiveStageDataSuccess',
            payload: { events: [] },
          },
        ],
      );
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

    describe('receiveStageDataSuccess', () => {
      it(`commits the ${types.RECEIVE_STAGE_DATA_SUCCESS} mutation`, () => {
        return testAction(
          actions.receiveStageDataSuccess,
          { ...stageData },
          state,
          [{ type: types.RECEIVE_STAGE_DATA_SUCCESS, payload: { events: [] } }],
          [],
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
      shouldFlashAMessage('There was an error fetching data for the selected stage');
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
      state = { ...state, currentGroup, startDate, endDate };
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
          shouldFlashAMessage('There was an error fetching median data for stages');
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
          shouldFlashAMessage('There was an error fetching value stream analytics stages.');
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

      shouldFlashAMessage(flashErrorMessage);
    });
  });

  describe('receiveGroupStagesSuccess', () => {
    it(`commits the ${types.RECEIVE_GROUP_STAGES_SUCCESS} mutation and dispatches 'setDefaultSelectedStage'`, () => {
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
        [{ type: 'setDefaultSelectedStage' }],
      );
    });
  });

  describe('setDefaultSelectedStage', () => {
    describe('when the `hasPathNavigation` feature flag is enabled', () => {
      beforeEach(() => {
        state = {
          ...state,
          featureFlags: {
            ...state.featureFlags,
            hasPathNavigation: true,
          },
        };
      });

      afterEach(() => {
        mock.restore();
      });

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

    describe('when the `hasPathNavigation` feature flag is disabled', () => {
      beforeEach(() => {
        state = {
          ...state,
          featureFlags: {
            ...state.featureFlags,
            hasPathNavigation: false,
          },
        };
      });

      afterEach(() => {
        mock.restore();
      });

      it("dispatches the 'fetchStageData' action", () => {
        return testAction(
          actions.setDefaultSelectedStage,
          null,
          state,
          [],
          [
            { type: 'setSelectedStage', payload: selectedStage },
            { type: 'fetchStageData', payload: selectedStageSlug },
          ],
        );
      });

      it.each`
        data
        ${[]}
        ${null}
      `('with $data will flash an error', ({ data }) => {
        actions.setDefaultSelectedStage(
          { getters: { activeStages: data }, dispatch: () => {} },
          {},
        );
        shouldFlashAMessage(flashErrorMessage);
      });

      it('will select the first active stage', () => {
        return testAction(
          actions.setDefaultSelectedStage,
          null,
          state,
          [],
          [
            { type: 'setSelectedStage', payload: stages[1] },
            { type: 'fetchStageData', payload: stages[1].slug },
          ],
        );
      });
    });
  });

  describe('updateStage', () => {
    const stageId = 'cool-stage';
    const payload = { hidden: true };

    beforeEach(() => {
      mock.onPut(stageEndpoint({ stageId }), payload).replyOnce(httpStatusCodes.OK, payload);
    });

    it('dispatches receiveUpdateStageSuccess and customStages/setSavingCustomStage', () => {
      return testAction(
        actions.updateStage,
        {
          id: stageId,
          ...payload,
        },
        state,
        [],
        [
          { type: 'requestUpdateStage' },
          { type: 'customStages/setSavingCustomStage' },
          {
            type: 'receiveUpdateStageSuccess',
            payload,
          },
        ],
      );
    });

    describe('with a failed request', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onPut(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.NOT_FOUND);
      });

      it('dispatches receiveUpdateStageError', () => {
        const data = {
          id: stageId,
          name: 'issue',
          ...payload,
        };
        return testAction(
          actions.updateStage,
          data,
          state,
          [],
          [
            { type: 'requestUpdateStage' },
            { type: 'customStages/setSavingCustomStage' },
            {
              type: 'receiveUpdateStageError',
              payload: {
                status: httpStatusCodes.NOT_FOUND,
                data,
              },
            },
          ],
        );
      });

      it('flashes an error if the stage name already exists', () => {
        return actions
          .receiveUpdateStageError(
            {
              commit: () => {},
              dispatch: () => Promise.resolve(),
              state,
            },
            {
              status: httpStatusCodes.UNPROCESSABLE_ENTITY,
              responseData: {
                errors: { name: ['is reserved'] },
              },
              data: {
                name: stageId,
              },
            },
          )
          .then(() => {
            shouldFlashAMessage(`'${stageId}' stage already exists`);
          });
      });

      it('flashes an error message', () => {
        return actions
          .receiveUpdateStageError(
            {
              dispatch: () => Promise.resolve(),
              commit: () => {},
              state,
            },
            { status: httpStatusCodes.BAD_REQUEST },
          )
          .then(() => {
            shouldFlashAMessage('There was a problem saving your custom stage, please try again');
          });
      });
    });

    describe('receiveUpdateStageSuccess', () => {
      const response = {
        title: 'NEW - COOL',
      };

      it('will dispatch fetchGroupStagesAndEvents', () =>
        testAction(
          actions.receiveUpdateStageSuccess,
          response,
          state,
          [{ type: types.RECEIVE_UPDATE_STAGE_SUCCESS }],
          [
            { type: 'fetchGroupStagesAndEvents' },
            { type: 'customStages/showEditForm', payload: response },
          ],
        ));

      it('will flash a success message', () => {
        return actions
          .receiveUpdateStageSuccess(
            {
              dispatch: () => {},
              commit: () => {},
            },
            response,
          )
          .then(() => {
            shouldFlashAMessage('Stage data updated', 'notice');
          });
      });

      describe('with an error', () => {
        it('will flash an error message', () =>
          actions
            .receiveUpdateStageSuccess(
              {
                dispatch: () => Promise.reject(),
                commit: () => {},
              },
              response,
            )
            .then(() => {
              shouldFlashAMessage('There was a problem refreshing the data, please try again');
            }));
      });
    });
  });

  describe('removeStage', () => {
    const stageId = 'cool-stage';

    beforeEach(() => {
      mock.onDelete(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.OK);
    });

    it('dispatches receiveRemoveStageSuccess with put request response data', () => {
      return testAction(
        actions.removeStage,
        stageId,
        state,
        [],
        [
          { type: 'requestRemoveStage' },
          {
            type: 'receiveRemoveStageSuccess',
          },
        ],
      );
    });

    describe('with a failed request', () => {
      beforeEach(() => {
        mock = new MockAdapter(axios);
        mock.onDelete(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.NOT_FOUND);
      });

      it('dispatches receiveRemoveStageError', () => {
        return testAction(
          actions.removeStage,
          stageId,
          state,
          [],
          [
            { type: 'requestRemoveStage' },
            {
              type: 'receiveRemoveStageError',
              payload: error,
            },
          ],
        );
      });

      it('flashes an error message', () => {
        actions.receiveRemoveStageError({ commit: () => {}, state }, {});
        shouldFlashAMessage('There was an error removing your custom stage, please try again');
      });
    });
  });

  describe('receiveRemoveStageSuccess', () => {
    const stageId = 'cool-stage';

    beforeEach(() => {
      mock.onDelete(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.OK);
      state = { currentGroup };
    });

    it('dispatches fetchCycleAnalyticsData', () => {
      return testAction(
        actions.receiveRemoveStageSuccess,
        stageId,
        state,
        [{ type: 'RECEIVE_REMOVE_STAGE_RESPONSE' }],
        [{ type: 'fetchCycleAnalyticsData' }],
      );
    });

    it('flashes a success message', () => {
      return actions
        .receiveRemoveStageSuccess(
          {
            dispatch: () => Promise.resolve(),
            commit: () => {},
            state,
          },
          {},
        )
        .then(() => shouldFlashAMessage('Stage removed', 'notice'));
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
      shouldFlashAMessage('There was an error fetching median data for stages');
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

  describe('reorderStage', () => {
    const stageId = 'cool-stage';
    const payload = { id: stageId, move_after_id: '2', move_before_id: '8' };

    describe('with no errors', () => {
      beforeEach(() => {
        mock.onPut(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.OK);
      });

      it(`dispatches the ${types.REQUEST_REORDER_STAGE} and ${types.RECEIVE_REORDER_STAGE_SUCCESS} actions`, () => {
        return testAction(
          actions.reorderStage,
          payload,
          state,
          [],
          [{ type: 'requestReorderStage' }, { type: 'receiveReorderStageSuccess' }],
        );
      });
    });

    describe('with errors', () => {
      beforeEach(() => {
        mock.onPut(stageEndpoint({ stageId })).replyOnce(httpStatusCodes.NOT_FOUND);
      });

      it(`dispatches the ${types.REQUEST_REORDER_STAGE} and ${types.RECEIVE_REORDER_STAGE_ERROR} actions `, () => {
        return testAction(
          actions.reorderStage,
          payload,
          state,
          [],
          [
            { type: 'requestReorderStage' },
            { type: 'receiveReorderStageError', payload: { status: httpStatusCodes.NOT_FOUND } },
          ],
        );
      });
    });
  });

  describe('receiveReorderStageError', () => {
    beforeEach(() => {});

    it(`commits the ${types.RECEIVE_REORDER_STAGE_ERROR} mutation and flashes an error`, () => {
      return testAction(
        actions.receiveReorderStageError,
        null,
        state,
        [
          {
            type: types.RECEIVE_REORDER_STAGE_ERROR,
          },
        ],
        [],
      ).then(() => {
        shouldFlashAMessage(
          'There was an error updating the stage order. Please try reloading the page.',
        );
      });
    });
  });

  describe('receiveReorderStageSuccess', () => {
    it(`commits the ${types.RECEIVE_REORDER_STAGE_SUCCESS} mutation`, () => {
      return testAction(
        actions.receiveReorderStageSuccess,
        null,
        state,
        [{ type: types.RECEIVE_REORDER_STAGE_SUCCESS }],
        [],
      );
    });
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
      it(`with a selectedValueStream in state commits the ${types.RECEIVE_VALUE_STREAMS_SUCCESS} mutation and dispatches 'fetchValueStreamData'`, () => {
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
          [{ type: 'fetchValueStreamData' }],
        );
      });

      it(`commits the ${types.RECEIVE_VALUE_STREAMS_SUCCESS} mutation and dispatches 'setSelectedValueStream'`, () => {
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
          [{ type: 'setSelectedValueStream', payload: selectedValueStream }],
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

  describe('setFilters', () => {
    it('dispatches the fetchCycleAnalyticsData action', () => {
      return testAction(actions.setFilters, null, state, [], [{ type: 'fetchCycleAnalyticsData' }]);
    });
  });
});
