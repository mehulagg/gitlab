import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import testAction from 'helpers/vuex_action_helper';
import * as actions from 'ee/analytics/cycle_analytics/store/modules/filters/actions';
import * as types from 'ee/analytics/cycle_analytics/store/modules/filters/mutation_types';
import initialState from 'ee/analytics/cycle_analytics/store/modules/filters/state';
import httpStatusCodes from '~/lib/utils/http_status';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { filterMilestones, filterUsers, filterLabels } from '../../../mock_data';

const milestonesPath = 'fake_milestones_path';
const labelsPath = 'fake_labels_path';

jest.mock('~/flash');

describe('Filters actions', () => {
  let state;
  let mock;
  let mockDispatch;
  let mockCommit;

  beforeEach(() => {
    state = initialState();
    mock = new MockAdapter(axios);

    mockDispatch = jest.fn().mockResolvedValue();
    mockCommit = jest.fn();
  });

  afterEach(() => {
    mock.restore();
  });

  describe('initialize', () => {
    const initialData = {
      milestonesPath,
      labelsPath,
      selectedAuthor: 'Mr cool',
      selectedMilestone: 'NEXT',
    };

    it('dispatches setPaths, setSelectedFilters', () => {
      return actions
        .initialize(
          {
            state,
            dispatch: mockDispatch,
            commit: mockCommit,
          },
          initialData,
        )
        .then(() => {
          expect(mockDispatch).toHaveBeenCalledTimes(2);
          expect(mockDispatch).toHaveBeenCalledWith('setPaths', initialData);
          expect(mockDispatch).toHaveBeenCalledWith('setSelectedFilters', initialData, {
            root: true,
          });
        });
    });

    it(`commits the ${types.INITIALIZE}`, () => {
      return actions
        .initialize(
          {
            state,
            dispatch: mockDispatch,
            commit: mockCommit,
          },
          initialData,
        )
        .then(() => {
          expect(mockCommit).toHaveBeenCalledWith(types.INITIALIZE, initialData);
        });
    });
  });

  describe('setFilters', () => {
    const nextFilters = {
      selectedAuthor: 'Mr cool',
      selectedMilestone: 'NEXT',
    };

    it('dispatches the root/setSelectedFilters and root/fetchCycleAnalyticsData actions', () => {
      return testAction(
        actions.setFilters,
        nextFilters,
        state,
        [],
        [
          {
            type: 'setSelectedFilters',
            payload: nextFilters,
          },
          {
            type: 'fetchCycleAnalyticsData',
            payload: null,
          },
        ],
      );
    });

    it('sets the selectedLabels from the labels available', () => {
      return testAction(
        actions.setFilters,
        { ...nextFilters, selectedLabels: [filterLabels[1].title] },
        { ...state, labels: { data: filterLabels } },
        [],
        [
          {
            type: 'setSelectedFilters',
            payload: {
              ...nextFilters,
              selectedLabels: [filterLabels[1].title],
            },
          },
          {
            type: 'fetchCycleAnalyticsData',
            payload: null,
          },
        ],
      );
    });
  });

  describe('setPaths', () => {
    it('sets the api paths', () => {
      return testAction(
        actions.setPaths,
        { milestonesPath, labelsPath },
        state,
        [
          { payload: 'fake_milestones_path.json', type: types.SET_MILESTONES_PATH },
          { payload: 'fake_labels_path.json', type: types.SET_LABELS_PATH },
        ],
        [],
      );
    });
  });

  describe('fetchAuthors', () => {
    describe('success', () => {
      beforeEach(() => {
        mock.onAny().replyOnce(httpStatusCodes.OK, filterUsers);
      });

      it('dispatches RECEIVE_AUTHORS_SUCCESS with received data', () => {
        return testAction(
          actions.fetchAuthors,
          null,
          state,
          [
            { type: types.REQUEST_AUTHORS },
            { type: types.RECEIVE_AUTHORS_SUCCESS, payload: filterUsers },
          ],
          [],
        ).then(({ data }) => {
          expect(data).toBe(filterUsers);
        });
      });
    });

    describe('error', () => {
      beforeEach(() => {
        mock.onAny().replyOnce(httpStatusCodes.SERVICE_UNAVAILABLE);
      });

      it('dispatches RECEIVE_AUTHORS_ERROR', () => {
        return testAction(
          actions.fetchAuthors,
          null,
          state,
          [
            { type: types.REQUEST_AUTHORS },
            {
              type: types.RECEIVE_AUTHORS_ERROR,
              payload: httpStatusCodes.SERVICE_UNAVAILABLE,
            },
          ],
          [],
        ).then(() => expect(createFlash).toHaveBeenCalled());
      });
    });
  });

  describe('fetchMilestones', () => {
    describe('success', () => {
      beforeEach(() => {
        mock.onGet(milestonesPath).replyOnce(httpStatusCodes.OK, filterMilestones);
      });

      it('dispatches RECEIVE_MILESTONES_SUCCESS with received data', () => {
        return testAction(
          actions.fetchMilestones,
          null,
          { ...state, milestonesPath },
          [
            { type: types.REQUEST_MILESTONES },
            { type: types.RECEIVE_MILESTONES_SUCCESS, payload: filterMilestones },
          ],
          [],
        ).then(({ data }) => {
          expect(data).toBe(filterMilestones);
        });
      });
    });

    describe('error', () => {
      beforeEach(() => {
        mock.onAny().replyOnce(httpStatusCodes.SERVICE_UNAVAILABLE);
      });

      it('dispatches RECEIVE_MILESTONES_ERROR', () => {
        return testAction(
          actions.fetchMilestones,
          null,
          state,
          [
            { type: types.REQUEST_MILESTONES },
            {
              type: types.RECEIVE_MILESTONES_ERROR,
              payload: httpStatusCodes.SERVICE_UNAVAILABLE,
            },
          ],
          [],
        ).then(() => expect(createFlash).toHaveBeenCalled());
      });
    });
  });

  describe('fetchAssignees', () => {
    describe('success', () => {
      beforeEach(() => {
        mock.onAny().replyOnce(httpStatusCodes.OK, filterUsers);
      });

      it('dispatches RECEIVE_ASSIGNEES_SUCCESS with received data', () => {
        return testAction(
          actions.fetchAssignees,
          null,
          { ...state, milestonesPath },
          [
            { type: types.REQUEST_ASSIGNEES },
            { type: types.RECEIVE_ASSIGNEES_SUCCESS, payload: filterUsers },
          ],
          [],
        ).then(({ data }) => {
          expect(data).toBe(filterUsers);
        });
      });
    });

    describe('error', () => {
      beforeEach(() => {
        mock.onAny().replyOnce(httpStatusCodes.SERVICE_UNAVAILABLE);
      });

      it('dispatches RECEIVE_ASSIGNEES_ERROR', () => {
        return testAction(
          actions.fetchAssignees,
          null,
          state,
          [
            { type: types.REQUEST_ASSIGNEES },
            {
              type: types.RECEIVE_ASSIGNEES_ERROR,
              payload: httpStatusCodes.SERVICE_UNAVAILABLE,
            },
          ],
          [],
        ).then(() => expect(createFlash).toHaveBeenCalled());
      });
    });
  });

  describe('fetchLabels', () => {
    describe('success', () => {
      beforeEach(() => {
        mock.onGet(labelsPath).replyOnce(httpStatusCodes.OK, filterLabels);
      });

      it('dispatches RECEIVE_LABELS_SUCCESS with received data', () => {
        return testAction(
          actions.fetchLabels,
          null,
          { ...state, labelsPath },
          [
            { type: types.REQUEST_LABELS },
            { type: types.RECEIVE_LABELS_SUCCESS, payload: filterLabels },
          ],
          [],
        ).then(({ data }) => {
          expect(data).toBe(filterLabels);
        });
      });
    });

    describe('error', () => {
      beforeEach(() => {
        mock.onAny().replyOnce(httpStatusCodes.SERVICE_UNAVAILABLE);
      });

      it('dispatches RECEIVE_LABELS_ERROR', () => {
        return testAction(
          actions.fetchLabels,
          null,
          state,
          [
            { type: types.REQUEST_LABELS },
            {
              type: types.RECEIVE_LABELS_ERROR,
              payload: httpStatusCodes.SERVICE_UNAVAILABLE,
            },
          ],
          [],
        ).then(() => expect(createFlash).toHaveBeenCalled());
      });
    });
  });
});
