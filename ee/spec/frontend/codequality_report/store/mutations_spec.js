import * as types from 'ee/codequality_report/store/mutation_types';
import mutations from 'ee/codequality_report/store/mutations';
import { parsedIssues } from '../mock_data';

describe('Codequality report mutations', () => {
  let state;

  const defaultState = {
    pageInfo: {},
  };

  beforeEach(() => {
    state = defaultState;
  });

  describe('set page', () => {
    it('should set page', () => {
      mutations[types.SET_PAGE](state, 4);
      expect(state.pageInfo.page).toBe(4);
    });
  });

  describe('request report', () => {
    it('should set the loading flag', () => {
      mutations[types.REQUEST_REPORT](state);
      expect(state.isLoadingCodequality).toBe(true);
    });
  });

  describe('receive report success', () => {
    it('should set issue info and clear the loading flag', () => {
      mutations[types.RECEIVE_REPORT_SUCCESS](state, parsedIssues);

      expect(state.isLoadingCodequality).toBe(false);
      expect(state.allCodequalityIssues).toBe(parsedIssues);
      expect(state.pageInfo.total).toBe(parsedIssues.length);
    });
  });

  describe('receive report error', () => {
    it('should set error info and clear the loading flag', () => {
      mutations[types.RECEIVE_REPORT_ERROR](state, new Error());

      expect(state.isLoadingCodequality).toBe(false);
      expect(state.loadingCodequalityFailed).toBe(true);
      expect(state.allCodequalityIssues).toEqual([]);
      expect(state.codeQualityError).toEqual(new Error());
      expect(state.pageInfo.total).toBe(0);
    });
  });
});
