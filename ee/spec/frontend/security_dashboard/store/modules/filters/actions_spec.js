import testAction from 'helpers/vuex_action_helper';
import createState from 'ee/security_dashboard/store/modules/filters/state';
import * as types from 'ee/security_dashboard/store/modules/filters/mutation_types';
import * as actions from 'ee/security_dashboard/store/modules/filters/actions';
import { DISMISSAL_STATES } from 'ee/security_dashboard/store/modules/filters/constants';
import Tracking from '~/tracking';

jest.mock('~/lib/utils/url_utility', () => ({
  getParameterValues: jest.fn().mockReturnValue([]),
}));

describe('filters actions', () => {
  beforeEach(() => {
    jest.spyOn(Tracking, 'event').mockImplementation(() => {});
  });

  describe('setFilter', () => {
    it('should commit the SET_FILTER mutation', () => {
      const state = createState();
      const payload = { reportType: ['SAST'] };

      return testAction(actions.setFilter, payload, state, [
        {
          type: types.SET_FILTER,
          payload: { report_type: ['sast'] },
        },
      ]);
    });
  });

  describe('setHideDismissed', () => {
    it.each`
      value    | expected
      ${true}  | ${DISMISSAL_STATES.DISMISSED}
      ${false} | ${DISMISSAL_STATES.ALL}
    `(
      'should commit the SET_HIDE_DISMISSED mutation with "$expected" when called with $value',
      ({ value, expected }) => {
        const state = createState();

        return testAction(actions.setHideDismissed, value, state, [
          {
            type: types.SET_HIDE_DISMISSED,
            payload: expected,
          },
        ]);
      },
    );
  });
});
