import testAction from 'helpers/vuex_action_helper';
import createState from 'ee/security_dashboard/store/modules/filters/state';
import * as types from 'ee/security_dashboard/store/modules/filters/mutation_types';
import * as actions from 'ee/security_dashboard/store/modules/filters/actions';
import Tracking from '~/tracking';
import { getParameterValues } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility', () => ({
  getParameterValues: jest.fn().mockReturnValue([]),
}));

describe('filters actions', () => {
  beforeEach(() => {
    jest.spyOn(Tracking, 'event').mockImplementation(() => {});
  });

  describe('setFilter', () => {
    it('should commit the SET_FILTER mutuation', done => {
      const state = createState();
      const payload = { filterId: 'report_type', optionId: 'sast' };

      testAction(
        actions.setFilter,
        payload,
        state,
        [
          {
            type: types.SET_FILTER,
            payload,
          },
        ],
        [],
        done,
      );
    });

    it('should commit the SET_FILTER mutuation passing through lazy = true', done => {
      const state = createState();
      const payload = { filterId: 'report_type', optionId: 'sast', lazy: true };

      testAction(
        actions.setFilter,
        payload,
        state,
        [
          {
            type: types.SET_FILTER,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });

  describe('setHideDismissedToggleInitialState', () => {
    [
      {
        description: 'should set hideDismissed to true if scope param is not present',
        returnValue: [],
        hideDismissedValue: true,
      },
      {
        description: 'should set hideDismissed to false if scope param is "all"',
        returnValue: ['all'],
        hideDismissedValue: false,
      },
      {
        description: 'should set hideDismissed to true if scope param is "dismissed"',
        returnValue: ['dismissed'],
        hideDismissedValue: true,
      },
    ].forEach(testCase => {
      it(testCase.description, done => {
        getParameterValues.mockReturnValue(testCase.returnValue);
        const state = createState();
        testAction(
          actions.setHideDismissedToggleInitialState,
          {},
          state,
          [
            {
              type: types.SET_TOGGLE_VALUE,
              payload: {
                key: 'hideDismissed',
                value: testCase.hideDismissedValue,
              },
            },
          ],
          [],
          done,
        );
      });
    });
  });

  describe('setToggleValue', () => {
    it('should commit the SET_TOGGLE_VALUE mutation', done => {
      const state = createState();
      const payload = { key: 'foo', value: 'bar' };

      testAction(
        actions.setToggleValue,
        payload,
        state,
        [
          {
            type: types.SET_TOGGLE_VALUE,
            payload,
          },
        ],
        [],
        done,
      );
    });
  });
});
