import * as actions from 'ee/security_dashboard/store/modules/filters/actions';
import { DISMISSAL_STATES } from 'ee/security_dashboard/store/modules/filters/constants';
import * as types from 'ee/security_dashboard/store/modules/filters/mutation_types';
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
    it('should commit the SET_FILTER mutation with the right casing', () => {
      const payload = {
        oneWord: ['ABC', 'DEF'],
        twoWords: ['123', '456'],
        threeTotalWords: ['Abc123', 'dEF456'],
      };

      return testAction(actions.setFilter, payload, undefined, [
        {
          type: types.SET_FILTER,
          payload: {
            one_word: ['abc', 'def'],
            two_words: ['123', '456'],
            three_total_words: ['abc123', 'def456'],
          },
        },
      ]);
    });
  });

  describe('setHideDismissed', () => {
    it.each`
      isHidden | expected
      ${true}  | ${DISMISSAL_STATES.DISMISSED}
      ${false} | ${DISMISSAL_STATES.ALL}
    `(
      'should commit the SET_HIDE_DISMISSED mutation with "$expected" when called with $isHidden',
      ({ isHidden, expected }) => {
        return testAction(actions.setHideDismissed, isHidden, undefined, [
          {
            type: types.SET_HIDE_DISMISSED,
            payload: expected,
          },
        ]);
      },
    );
  });
});
