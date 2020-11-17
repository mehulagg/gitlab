import * as actions from 'ee/security_dashboard/store/modules/filters/actions';
import * as types from 'ee/security_dashboard/store/modules/filters/mutation_types';
import createState from 'ee/security_dashboard/store/modules/filters/state';
import testAction from 'helpers/vuex_action_helper';
import Tracking from '~/tracking';

jest.mock('~/lib/utils/url_utility', () => ({
  getParameterValues: jest.fn().mockReturnValue([]),
}));

describe('filters actions', () => {
  beforeEach(() => {
    jest.spyOn(Tracking, 'event').mockImplementation(() => {});
  });

  describe('setFilter', () => {
    it('should commit the SET_FILTER mutuation', () => {
      const state = createState();
      const payload = { reportType: ['sast'] };

      return testAction(actions.setFilter, payload, state, [
        {
          type: types.SET_FILTER,
          payload,
        },
      ]);
    });
  });

  describe('toggleHideDismissed', () => {
    it('should commit the TOGGLE_HIDE_DISMISSED mutation', () => {
      const state = createState();

      return testAction(actions.toggleHideDismissed, undefined, state, [
        {
          type: types.TOGGLE_HIDE_DISMISSED,
        },
      ]);
    });
  });
});
