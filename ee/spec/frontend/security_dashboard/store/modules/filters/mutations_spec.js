import createState from 'ee/security_dashboard/store/modules/filters/state';
import {
  SET_FILTER,
  SET_HIDE_DISMISSED,
} from 'ee/security_dashboard/store/modules/filters/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/filters/mutations';
import { DISMISSAL_STATES } from 'ee/security_dashboard/store/modules/filters/constants';
import { severityFilter } from 'ee/security_dashboard/helpers';

const criticalOption = severityFilter.options.find(x => x.id === 'CRITICAL');
const highOption = severityFilter.options.find(x => x.id === 'HIGH');

describe('filters module mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('SET_FILTER', () => {
    it.each`
      options                               | expected
      ${[]}                                 | ${[]}
      ${[criticalOption.id]}                | ${[criticalOption.id.toLowerCase()]}
      ${[criticalOption.id, highOption.id]} | ${[criticalOption.id.toLowerCase(), highOption.id.toLowerCase()]}
    `('sets the filter to $options', ({ options, expected }) => {
      mutations[SET_FILTER](state, { [severityFilter.id]: options });

      expect(state.filters[severityFilter.id]).toEqual(expected);
    });

    it('sets multiple filters correctly with the right casing', () => {
      const filter1 = { oneWord: ['ABC', 'DEF'] };
      const filter2 = { twoWords: ['123', '456'] };
      const filter3 = { threeTotalWords: ['Abc123', 'dEF456'] };

      mutations[SET_FILTER](state, filter1);
      mutations[SET_FILTER](state, filter2);
      mutations[SET_FILTER](state, filter3);

      expect(state.filters).toMatchObject({
        one_word: ['abc', 'def'],
        two_words: ['123', '456'],
        three_total_words: ['abc123', 'def456'],
      });
    });
  });

  describe('SET_HIDE_DISMISSED', () => {
    it.each(Object.values(DISMISSAL_STATES))(`sets scope filter to "%s"`, value => {
      mutations[SET_HIDE_DISMISSED](state, value);
      expect(state.filters.scope).toBe(value);
    });
  });
});
