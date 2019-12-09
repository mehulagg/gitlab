import * as actions from 'ee/analytics/productivity_analytics/store/modules/filters/actions';
import * as types from 'ee/analytics/productivity_analytics/store/modules/filters/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import { chartKeys } from 'ee/analytics/productivity_analytics/constants';
import getInitialState from 'ee/analytics/productivity_analytics/store/modules/filters/state';

describe('Productivity analytics filter actions', () => {
  let store;
  const currentYear = new Date().getFullYear();
  const startDate = new Date(currentYear, 8, 1);
  const endDate = new Date(currentYear, 8, 7);
  const groupNamespace = 'gitlab-org';
  const projectPath = 'gitlab-org/gitlab-test';

  beforeEach(() => {
    store = {
      commit: jest.fn(),
      dispatch: jest.fn(() => Promise.resolve()),
    };
  });

  describe('setGroupNamespace', () => {
    it('commits the SET_GROUP_NAMESPACE mutation', done => {
      actions
        .setGroupNamespace(store, groupNamespace)
        .then(() => {
          expect(store.commit).toHaveBeenCalledWith(types.SET_GROUP_NAMESPACE, groupNamespace);

          expect(store.dispatch.mock.calls[0]).toEqual([
            'charts/resetMainChartSelection',
            true,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[1]).toEqual([
            'charts/fetchChartData',
            chartKeys.main,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[2]).toEqual([
            'charts/fetchSecondaryChartData',
            null,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[3]).toEqual(['table/setPage', 0, { root: true }]);
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('setProjectPath', () => {
    it('commits the SET_PROJECT_PATH mutation', done => {
      actions
        .setProjectPath(store, projectPath)
        .then(() => {
          expect(store.commit).toHaveBeenCalledWith(types.SET_PROJECT_PATH, projectPath);

          expect(store.dispatch.mock.calls[0]).toEqual([
            'charts/resetMainChartSelection',
            true,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[1]).toEqual([
            'charts/fetchChartData',
            chartKeys.main,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[2]).toEqual([
            'charts/fetchSecondaryChartData',
            null,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[3]).toEqual(['table/setPage', 0, { root: true }]);
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('setFilters', () => {
    it('commits the SET_FILTERS mutation', done => {
      actions
        .setFilters(store, { author_username: 'root' })
        .then(() => {
          expect(store.commit).toHaveBeenCalledWith(types.SET_FILTERS, { authorUsername: 'root' });

          expect(store.dispatch.mock.calls[0]).toEqual([
            'charts/resetMainChartSelection',
            true,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[1]).toEqual([
            'charts/fetchChartData',
            chartKeys.main,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[2]).toEqual([
            'charts/fetchSecondaryChartData',
            null,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[3]).toEqual(['table/setPage', 0, { root: true }]);
        })
        .then(done)
        .catch(done.fail);
    });
  });

  describe('setDateRange', () => {
    it('commits the SET_DATE_RANGE mutation and fetches data by default', done => {
      actions
        .setDateRange(store, { startDate, endDate })
        .then(() => {
          expect(store.commit).toHaveBeenCalledWith(types.SET_DATE_RANGE, { startDate, endDate });

          expect(store.dispatch.mock.calls[0]).toEqual([
            'charts/resetMainChartSelection',
            true,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[1]).toEqual([
            'charts/fetchChartData',
            chartKeys.main,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[2]).toEqual([
            'charts/fetchSecondaryChartData',
            null,
            { root: true },
          ]);

          expect(store.dispatch.mock.calls[3]).toEqual(['table/setPage', 0, { root: true }]);
        })
        .then(done)
        .catch(done.fail);
    });

    it("commits the SET_DATE_RANGE mutation and doesn't fetch data when skipFetch=true", done =>
      testAction(
        actions.setDateRange,
        { skipFetch: true, startDate, endDate },
        getInitialState(),
        [
          {
            type: types.SET_DATE_RANGE,
            payload: { startDate, endDate },
          },
        ],
        [],
        done,
      ));
  });
});
