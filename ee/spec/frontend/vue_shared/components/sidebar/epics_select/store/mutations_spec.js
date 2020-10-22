import mutations from 'ee/vue_shared/components/sidebar/epics_select/store/mutations';
import createDefaultState from 'ee/vue_shared/components/sidebar/epics_select/store/state';

import * as types from 'ee/vue_shared/components/sidebar/epics_select/store/mutation_types';
import { DropdownVariant } from 'ee/vue_shared/components/sidebar/epics_select//constants';

import { mockEpic1, mockIssue } from '../../mock_data';

describe('EpicsSelect', () => {
  describe('store', () => {
    describe('mutations', () => {
      let state;

      beforeEach(() => {
        state = createDefaultState();
      });

      describe(types.SET_INITIAL_DATA, () => {
        it('should set provided `data` param props to state', () => {
          const data = {
            variant: DropdownVariant.Sidebar,
            groupId: mockEpic1.group_id,
            issueId: mockIssue.id,
            selectedEpic: mockEpic1,
            selectedEpicIssueId: mockIssue.epic_issue_id,
          };

          mutations[types.SET_INITIAL_DATA](state, data);

          expect(state).toHaveProperty('variant', data.variant);
          expect(state).toHaveProperty('groupId', data.groupId);
          expect(state).toHaveProperty('issueId', data.issueId);
          expect(state).toHaveProperty('selectedEpic', data.selectedEpic);
          expect(state).toHaveProperty('selectedEpicIssueId', data.selectedEpicIssueId);
        });
      });

      describe(types.SET_ISSUE_ID, () => {
        it('should set provided `issueId` param to state.issueId', () => {
          const issueId = mockIssue.id;

          mutations[types.SET_ISSUE_ID](state, issueId);

          expect(state).toHaveProperty('issueId', issueId);
        });
      });

      describe(types.SET_SEARCH_QUERY, () => {
        it('should set `searchQuery` param to state', () => {
          const searchQuery = 'foo';

          mutations[types.SET_SEARCH_QUERY](state, searchQuery);

          expect(state).toHaveProperty('searchQuery', searchQuery);
        });
      });

      describe(types.SET_SELECTED_EPIC, () => {
        it('should set `selectedEpic` param to state', () => {
          mutations[types.SET_SELECTED_EPIC](state, mockEpic1);

          expect(state).toHaveProperty('selectedEpic', mockEpic1);
        });
      });

      describe(types.REQUEST_EPICS, () => {
        it('should set `state.epicsFetchInProgress` to true', () => {
          mutations[types.REQUEST_EPICS](state);

          expect(state.epicsFetchInProgress).toBe(true);
        });
      });

      describe(types.RECEIVE_EPICS_SUCCESS, () => {
        it('should set `state.epicsFetchInProgress` to false `epics` param to state', () => {
          mutations[types.RECEIVE_EPICS_SUCCESS](state, { epics: [mockEpic1] });

          expect(state.epicsFetchInProgress).toBe(false);
          expect(state.epics).toEqual(expect.arrayContaining([mockEpic1]));
        });
      });

      describe(types.RECEIVE_EPICS_FAILURE, () => {
        it('should set `state.epicsFetchInProgress` to false', () => {
          mutations[types.RECEIVE_EPICS_FAILURE](state);

          expect(state.epicsFetchInProgress).toBe(false);
        });
      });

      describe(types.REQUEST_ISSUE_UPDATE, () => {
        it('should set `state.epicSelectInProgress` to true', () => {
          mutations[types.REQUEST_ISSUE_UPDATE](state);

          expect(state.epicSelectInProgress).toBe(true);
        });
      });

      describe(types.RECEIVE_ISSUE_UPDATE_SUCCESS, () => {
        it('should set `state.epicSelectInProgress` to false and `selectedEpic` & `selectedEpicIssueId` params to state', () => {
          mutations[types.RECEIVE_ISSUE_UPDATE_SUCCESS](state, {
            selectedEpic: mockEpic1,
            selectedEpicIssueId: mockIssue.epic_issue_id,
          });

          expect(state.epicSelectInProgress).toBe(false);
          expect(state.selectedEpic).toBe(mockEpic1);
          expect(state.selectedEpicIssueId).toBe(mockIssue.epic_issue_id);
        });
      });

      describe(types.RECEIVE_ISSUE_UPDATE_FAILURE, () => {
        it('should set `state.epicSelectInProgress` to false', () => {
          mutations[types.RECEIVE_ISSUE_UPDATE_FAILURE](state);

          expect(state.epicSelectInProgress).toBe(false);
        });
      });
    });
  });
});
