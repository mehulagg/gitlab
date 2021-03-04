import * as types from '~/boards/stores/mutation_types';
import mutations from '~/boards/stores/mutations';
import defaultState from '~/boards/stores/state';
import {
  mockLists,
  rawIssue,
  mockIssue,
  mockIssue2,
  mockGroupProjects,
  labels,
} from '../mock_data';

const expectNotImplemented = (action) => {
  it('is not implemented', () => {
    expect(action).toThrow(new Error('Not implemented!'));
  });
};

describe('Board Store Mutations', () => {
  let state;

  const initialBoardListsState = {
    'gid://gitlab/List/1': mockLists[0],
    'gid://gitlab/List/2': mockLists[1],
  };

  beforeEach(() => {
    state = defaultState();
  });

  describe('SET_INITIAL_BOARD_DATA', () => {
    it('Should set initial Boards data to state', () => {
      const boardId = 1;
      const fullPath = 'gitlab-org';
      const boardType = 'group';
      const disabled = false;
      const boardConfig = {
        milestoneTitle: 'Milestone 1',
      };
      const isEpicBoard = true;

      mutations[types.SET_INITIAL_BOARD_DATA](state, {
        boardId,
        fullPath,
        boardType,
        disabled,
        boardConfig,
        isEpicBoard,
      });

      expect(state.boardId).toEqual(boardId);
      expect(state.fullPath).toEqual(fullPath);
      expect(state.boardType).toEqual(boardType);
      expect(state.disabled).toEqual(disabled);
      expect(state.boardConfig).toEqual(boardConfig);
      expect(state.isEpicBoard).toEqual(isEpicBoard);
    });
  });

  describe('RECEIVE_BOARD_LISTS_SUCCESS', () => {
    it('Should set boardLists to state', () => {
      mutations[types.RECEIVE_BOARD_LISTS_SUCCESS](state, initialBoardListsState);

      expect(state.boardLists).toEqual(initialBoardListsState);
    });
  });

  describe('RECEIVE_BOARD_LISTS_FAILURE', () => {
    it('Should set error in state', () => {
      mutations[types.RECEIVE_BOARD_LISTS_FAILURE](state);

      expect(state.error).toEqual(
        'An error occurred while fetching the board lists. Please reload the page.',
      );
    });
  });

  describe('SET_ACTIVE_ID', () => {
    const expected = { id: 1, sidebarType: '' };

    beforeEach(() => {
      mutations.SET_ACTIVE_ID(state, expected);
    });

    it('updates activeListId to be the value that is passed', () => {
      expect(state.activeId).toBe(expected.id);
    });

    it('updates sidebarType to be the value that is passed', () => {
      expect(state.sidebarType).toBe(expected.sidebarType);
    });
  });

  describe('SET_FILTERS', () => {
    it('updates filterParams to be the value that is passed', () => {
      const filterParams = { labelName: 'label' };

      mutations.SET_FILTERS(state, filterParams);

      expect(state.filterParams).toBe(filterParams);
    });
  });

  describe('CREATE_LIST_FAILURE', () => {
    it('sets error message', () => {
      mutations.CREATE_LIST_FAILURE(state);

      expect(state.error).toEqual('An error occurred while creating the list. Please try again.');
    });
  });

  describe('RECEIVE_LABELS_REQUEST', () => {
    it('sets labelsLoading on state', () => {
      mutations.RECEIVE_LABELS_REQUEST(state);

      expect(state.labelsLoading).toEqual(true);
    });
  });

  describe('RECEIVE_LABELS_SUCCESS', () => {
    it('sets labels on state', () => {
      mutations.RECEIVE_LABELS_SUCCESS(state, labels);

      expect(state.labels).toEqual(labels);
      expect(state.labelsLoading).toEqual(false);
    });
  });

  describe('RECEIVE_LABELS_FAILURE', () => {
    it('sets error message', () => {
      mutations.RECEIVE_LABELS_FAILURE(state);

      expect(state.error).toEqual(
        'An error occurred while fetching labels. Please reload the page.',
      );
      expect(state.labelsLoading).toEqual(false);
    });
  });

  describe('GENERATE_DEFAULT_LISTS_FAILURE', () => {
    it('sets error message', () => {
      mutations.GENERATE_DEFAULT_LISTS_FAILURE(state);

      expect(state.error).toEqual(
        'An error occurred while generating lists. Please reload the page.',
      );
    });
  });

  describe('REQUEST_ADD_LIST', () => {
    expectNotImplemented(mutations.REQUEST_ADD_LIST);
  });

  describe('RECEIVE_ADD_LIST_SUCCESS', () => {
    it('adds list to boardLists state', () => {
      mutations.RECEIVE_ADD_LIST_SUCCESS(state, mockLists[0]);

      expect(state.boardLists).toEqual({
        [mockLists[0].id]: mockLists[0],
      });
    });
  });

  describe('RECEIVE_ADD_LIST_ERROR', () => {
    expectNotImplemented(mutations.RECEIVE_ADD_LIST_ERROR);
  });

  describe('MOVE_LIST', () => {
    it('updates boardLists state with reordered lists', () => {
      state = {
        ...state,
        boardLists: initialBoardListsState,
      };

      mutations.MOVE_LIST(state, {
        movedList: mockLists[0],
        listAtNewIndex: mockLists[1],
      });

      expect(state.boardLists).toEqual({
        'gid://gitlab/List/2': mockLists[1],
        'gid://gitlab/List/1': mockLists[0],
      });
    });
  });

  describe('UPDATE_LIST_FAILURE', () => {
    it('updates boardLists state with previous order and sets error message', () => {
      state = {
        ...state,
        boardLists: {
          'gid://gitlab/List/2': mockLists[1],
          'gid://gitlab/List/1': mockLists[0],
        },
        error: undefined,
      };

      mutations.UPDATE_LIST_FAILURE(state, initialBoardListsState);

      expect(state.boardLists).toEqual(initialBoardListsState);
      expect(state.error).toEqual('An error occurred while updating the list. Please try again.');
    });
  });

  describe('TOGGLE_LIST_COLLAPSED', () => {
    it('updates collapsed attribute of list in boardLists state', () => {
      const listId = 'gid://gitlab/List/1';
      state = {
        ...state,
        boardLists: {
          [listId]: mockLists[0],
        },
      };

      expect(state.boardLists[listId].collapsed).toEqual(false);

      mutations.TOGGLE_LIST_COLLAPSED(state, { listId, collapsed: true });

      expect(state.boardLists[listId].collapsed).toEqual(true);
    });
  });

  describe('REMOVE_LIST', () => {
    it('removes list from boardLists', () => {
      const [list, secondList] = mockLists;
      const expected = {
        [secondList.id]: secondList,
      };
      state = {
        ...state,
        boardLists: { ...initialBoardListsState },
      };

      mutations[types.REMOVE_LIST](state, list.id);

      expect(state.boardLists).toEqual(expected);
    });
  });

  describe('REMOVE_LIST_FAILURE', () => {
    it('restores lists from backup', () => {
      const backupLists = { ...initialBoardListsState };

      mutations[types.REMOVE_LIST_FAILURE](state, backupLists);

      expect(state.boardLists).toEqual(backupLists);
    });

    it('sets error state', () => {
      const backupLists = { ...initialBoardListsState };
      state = {
        ...state,
        error: undefined,
      };

      mutations[types.REMOVE_LIST_FAILURE](state, backupLists);

      expect(state.error).toEqual('An error occurred while removing the list. Please try again.');
    });
  });

  describe('RESET_ISSUES', () => {
    it('should remove issues from boardItemsByListId state', () => {
      const boardItemsByListId = {
        'gid://gitlab/List/1': [mockIssue.id],
      };

      state = {
        ...state,
        boardItemsByListId,
      };

      mutations[types.RESET_ISSUES](state);

      expect(state.boardItemsByListId).toEqual({ 'gid://gitlab/List/1': [] });
    });
  });

  describe('RECEIVE_ITEMS_FOR_LIST_SUCCESS', () => {
    it('updates boardItemsByListId and issues on state', () => {
      const listIssues = {
        'gid://gitlab/List/1': [mockIssue.id],
      };
      const issues = {
        1: mockIssue,
      };

      state = {
        ...state,
        boardItemsByListId: {
          'gid://gitlab/List/1': [],
        },
        boardItems: {},
        boardLists: initialBoardListsState,
      };

      const listPageInfo = {
        'gid://gitlab/List/1': {
          endCursor: '',
          hasNextPage: false,
        },
      };

      mutations.RECEIVE_ITEMS_FOR_LIST_SUCCESS(state, {
        listItems: { listData: listIssues, boardItems: issues },
        listPageInfo,
        listId: 'gid://gitlab/List/1',
      });

      expect(state.boardItemsByListId).toEqual(listIssues);
      expect(state.boardItems).toEqual(issues);
    });
  });

  describe('RECEIVE_ITEMS_FOR_LIST_FAILURE', () => {
    it('sets error message', () => {
      state = {
        ...state,
        boardLists: initialBoardListsState,
        error: undefined,
      };

      const listId = 'gid://gitlab/List/1';

      mutations.RECEIVE_ITEMS_FOR_LIST_FAILURE(state, listId);

      expect(state.error).toEqual(
        'An error occurred while fetching the board issues. Please reload the page.',
      );
    });
  });

  describe('REQUEST_ADD_ISSUE', () => {
    expectNotImplemented(mutations.REQUEST_ADD_ISSUE);
  });

  describe('UPDATE_ISSUE_BY_ID', () => {
    const issueId = '1';
    const prop = 'id';
    const value = '2';
    const issue = { [issueId]: { id: 1, title: 'Issue' } };

    beforeEach(() => {
      state = {
        ...state,
        error: undefined,
        boardItems: {
          ...issue,
        },
      };
    });

    describe('when the issue is in state', () => {
      it('updates the property of the correct issue', () => {
        mutations.UPDATE_ISSUE_BY_ID(state, {
          issueId,
          prop,
          value,
        });

        expect(state.boardItems[issueId]).toEqual({ ...issue[issueId], id: '2' });
      });
    });

    describe('when the issue is not in state', () => {
      it('throws an error', () => {
        expect(() => {
          mutations.UPDATE_ISSUE_BY_ID(state, {
            issueId: '3',
            prop,
            value,
          });
        }).toThrow(new Error('No issue found.'));
      });
    });
  });

  describe('RECEIVE_ADD_ISSUE_SUCCESS', () => {
    expectNotImplemented(mutations.RECEIVE_ADD_ISSUE_SUCCESS);
  });

  describe('RECEIVE_ADD_ISSUE_ERROR', () => {
    expectNotImplemented(mutations.RECEIVE_ADD_ISSUE_ERROR);
  });

  describe('MOVE_ISSUE', () => {
    it('updates boardItemsByListId, moving issue between lists', () => {
      const listIssues = {
        'gid://gitlab/List/1': [mockIssue.id, mockIssue2.id],
        'gid://gitlab/List/2': [],
      };

      const issues = {
        1: mockIssue,
        2: mockIssue2,
      };

      state = {
        ...state,
        boardItemsByListId: listIssues,
        boardLists: initialBoardListsState,
        boardItems: issues,
      };

      mutations.MOVE_ISSUE(state, {
        originalIssue: mockIssue2,
        fromListId: 'gid://gitlab/List/1',
        toListId: 'gid://gitlab/List/2',
      });

      const updatedListIssues = {
        'gid://gitlab/List/1': [mockIssue.id],
        'gid://gitlab/List/2': [mockIssue2.id],
      };

      expect(state.boardItemsByListId).toEqual(updatedListIssues);
    });
  });

  describe('MOVE_ISSUE_SUCCESS', () => {
    it('updates issue in issues state', () => {
      const issues = {
        436: { id: rawIssue.id },
      };

      state = {
        ...state,
        boardItems: issues,
      };

      mutations.MOVE_ISSUE_SUCCESS(state, {
        issue: rawIssue,
      });

      expect(state.boardItems).toEqual({ 436: { ...mockIssue, id: 436 } });
    });
  });

  describe('MOVE_ISSUE_FAILURE', () => {
    it('updates boardItemsByListId, reverting moving issue between lists, and sets error message', () => {
      const listIssues = {
        'gid://gitlab/List/1': [mockIssue.id],
        'gid://gitlab/List/2': [mockIssue2.id],
      };

      state = {
        ...state,
        boardItemsByListId: listIssues,
        boardLists: initialBoardListsState,
      };

      mutations.MOVE_ISSUE_FAILURE(state, {
        originalIssue: mockIssue2,
        fromListId: 'gid://gitlab/List/1',
        toListId: 'gid://gitlab/List/2',
        originalIndex: 1,
      });

      const updatedListIssues = {
        'gid://gitlab/List/1': [mockIssue.id, mockIssue2.id],
        'gid://gitlab/List/2': [],
      };

      expect(state.boardItemsByListId).toEqual(updatedListIssues);
      expect(state.error).toEqual('An error occurred while moving the issue. Please try again.');
    });
  });

  describe('REQUEST_UPDATE_ISSUE', () => {
    expectNotImplemented(mutations.REQUEST_UPDATE_ISSUE);
  });

  describe('RECEIVE_UPDATE_ISSUE_SUCCESS', () => {
    expectNotImplemented(mutations.RECEIVE_UPDATE_ISSUE_SUCCESS);
  });

  describe('RECEIVE_UPDATE_ISSUE_ERROR', () => {
    expectNotImplemented(mutations.RECEIVE_UPDATE_ISSUE_ERROR);
  });

  describe('CREATE_ISSUE_FAILURE', () => {
    it('sets error message on state', () => {
      mutations.CREATE_ISSUE_FAILURE(state);

      expect(state.error).toBe('An error occurred while creating the issue. Please try again.');
    });
  });

  describe('ADD_ISSUE_TO_LIST', () => {
    it('adds issue to issues state and issue id in list in boardItemsByListId', () => {
      const listIssues = {
        'gid://gitlab/List/1': [mockIssue.id],
      };
      const issues = {
        1: mockIssue,
      };

      state = {
        ...state,
        boardItemsByListId: listIssues,
        boardItems: issues,
        boardLists: initialBoardListsState,
      };

      expect(state.boardLists['gid://gitlab/List/1'].issuesCount).toBe(1);

      mutations.ADD_ISSUE_TO_LIST(state, { list: mockLists[0], issue: mockIssue2 });

      expect(state.boardItemsByListId['gid://gitlab/List/1']).toContain(mockIssue2.id);
      expect(state.boardItems[mockIssue2.id]).toEqual(mockIssue2);
      expect(state.boardLists['gid://gitlab/List/1'].issuesCount).toBe(2);
    });
  });

  describe('ADD_ISSUE_TO_LIST_FAILURE', () => {
    it('removes issue id from list in boardItemsByListId and sets error message', () => {
      const listIssues = {
        'gid://gitlab/List/1': [mockIssue.id, mockIssue2.id],
      };
      const issues = {
        1: mockIssue,
        2: mockIssue2,
      };

      state = {
        ...state,
        boardItemsByListId: listIssues,
        boardItems: issues,
        boardLists: initialBoardListsState,
      };

      mutations.ADD_ISSUE_TO_LIST_FAILURE(state, { list: mockLists[0], issueId: mockIssue2.id });

      expect(state.boardItemsByListId['gid://gitlab/List/1']).not.toContain(mockIssue2.id);
      expect(state.error).toBe('An error occurred while creating the issue. Please try again.');
    });
  });

  describe('REMOVE_ISSUE_FROM_LIST', () => {
    it('removes issue id from list in boardItemsByListId and deletes issue from state', () => {
      const listIssues = {
        'gid://gitlab/List/1': [mockIssue.id, mockIssue2.id],
      };
      const issues = {
        1: mockIssue,
        2: mockIssue2,
      };

      state = {
        ...state,
        boardItemsByListId: listIssues,
        boardItems: issues,
        boardLists: initialBoardListsState,
      };

      mutations.ADD_ISSUE_TO_LIST_FAILURE(state, { list: mockLists[0], issueId: mockIssue2.id });

      expect(state.boardItemsByListId['gid://gitlab/List/1']).not.toContain(mockIssue2.id);
      expect(state.boardItems).not.toContain(mockIssue2);
    });
  });

  describe('SET_ASSIGNEE_LOADING', () => {
    it('sets isSettingAssignees to the value passed', () => {
      mutations.SET_ASSIGNEE_LOADING(state, true);

      expect(state.isSettingAssignees).toBe(true);
    });
  });

  describe('SET_CURRENT_PAGE', () => {
    expectNotImplemented(mutations.SET_CURRENT_PAGE);
  });

  describe('TOGGLE_EMPTY_STATE', () => {
    expectNotImplemented(mutations.TOGGLE_EMPTY_STATE);
  });

  describe('REQUEST_GROUP_PROJECTS', () => {
    it('Should set isLoading in groupProjectsFlags to true in state when fetchNext is false', () => {
      mutations[types.REQUEST_GROUP_PROJECTS](state, false);

      expect(state.groupProjectsFlags.isLoading).toBe(true);
    });

    it('Should set isLoading in groupProjectsFlags to true in state when fetchNext is true', () => {
      mutations[types.REQUEST_GROUP_PROJECTS](state, true);

      expect(state.groupProjectsFlags.isLoadingMore).toBe(true);
    });
  });

  describe('RECEIVE_GROUP_PROJECTS_SUCCESS', () => {
    it('Should set groupProjects and pageInfo to state and isLoading in groupProjectsFlags to false', () => {
      mutations[types.RECEIVE_GROUP_PROJECTS_SUCCESS](state, {
        projects: mockGroupProjects,
        pageInfo: { hasNextPage: false },
      });

      expect(state.groupProjects).toEqual(mockGroupProjects);
      expect(state.groupProjectsFlags.isLoading).toBe(false);
      expect(state.groupProjectsFlags.pageInfo).toEqual({ hasNextPage: false });
    });

    it('Should merge projects in groupProjects in state when fetchNext is true', () => {
      state = {
        ...state,
        groupProjects: [mockGroupProjects[0]],
      };

      mutations[types.RECEIVE_GROUP_PROJECTS_SUCCESS](state, {
        projects: [mockGroupProjects[1]],
        fetchNext: true,
      });

      expect(state.groupProjects).toEqual(mockGroupProjects);
    });
  });

  describe('RECEIVE_GROUP_PROJECTS_FAILURE', () => {
    it('Should set error in state and isLoading in groupProjectsFlags to false', () => {
      mutations[types.RECEIVE_GROUP_PROJECTS_FAILURE](state);

      expect(state.error).toEqual(
        'An error occurred while fetching group projects. Please try again.',
      );
      expect(state.groupProjectsFlags.isLoading).toBe(false);
    });
  });

  describe('SET_SELECTED_PROJECT', () => {
    it('Should set selectedProject to state', () => {
      mutations[types.SET_SELECTED_PROJECT](state, mockGroupProjects[0]);

      expect(state.selectedProject).toEqual(mockGroupProjects[0]);
    });
  });

  describe('ADD_BOARD_ITEM_TO_SELECTION', () => {
    it('Should add boardItem to selectedBoardItems state', () => {
      expect(state.selectedBoardItems).toEqual([]);

      mutations[types.ADD_BOARD_ITEM_TO_SELECTION](state, mockIssue);

      expect(state.selectedBoardItems).toEqual([mockIssue]);
    });
  });

  describe('REMOVE_BOARD_ITEM_FROM_SELECTION', () => {
    it('Should remove boardItem to selectedBoardItems state', () => {
      state.selectedBoardItems = [mockIssue];

      mutations[types.REMOVE_BOARD_ITEM_FROM_SELECTION](state, mockIssue);

      expect(state.selectedBoardItems).toEqual([]);
    });
  });

  describe('RESET_BOARD_ITEM_SELECTION', () => {
    it('Should reset selectedBoardItems state', () => {
      state.selectedBoardItems = [mockIssue];

      mutations[types.RESET_BOARD_ITEM_SELECTION](state, mockIssue);

      expect(state.selectedBoardItems).toEqual([]);
    });
  });
});
