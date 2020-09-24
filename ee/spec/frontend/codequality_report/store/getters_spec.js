import * as getters from 'ee/codequality_report/store/getters';
import { parsedIssues } from '../mock_data';

describe('Codequality report getters', () => {
  let state;

  const defaultState = {
    allCodequalityIssues: parsedIssues,
  };

  beforeEach(() => {
    state = defaultState;
  });

  describe('codequalityIssues', () => {
    it('gets the current page of issues', () => {
      expect(
        getters.codequalityIssues({ pageInfo: { page: 1, perPage: 2, total: 3 }, ...state }),
      ).toEqual(parsedIssues.slice(0, 2));
      expect(
        getters.codequalityIssues({ pageInfo: { page: 2, perPage: 2, total: 3 }, ...state }),
      ).toEqual(parsedIssues.slice(2, 3));
    });
  });

  describe('codequalityIssueTotal', () => {
    it('gets the total number of codequality issues', () => {
      expect(getters.codequalityIssueTotal(state)).toBe(parsedIssues.length);
    });
  });
});
