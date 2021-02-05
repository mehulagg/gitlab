import mutations from 'ee/boards/stores/mutations';
import { mockIssue, mockIssue2, mockEpics, mockEpic, mockLists } from '../mock_data';

const expectNotImplemented = (action) => {
  it('is not implemented', () => {
    expect(action).toThrow(new Error('Not implemented!'));
  });
};

const epicId = mockEpic.id;

const initialBoardListsState = {
  'gid://gitlab/List/1': mockLists[0],
  'gid://gitlab/List/2': mockLists[1],
};

let state = {
  issuesByListId: {},
  issues: {},
  boardLists: initialBoardListsState,
  epicsFlags: {
    [epicId]: { isLoading: true },
  },
};

describe('SET_SHOW_LABELS', () => {
  it('updates isShowingLabels', () => {
    state = {
      ...state,
      isShowingLabels: true,
    };

    mutations.SET_SHOW_LABELS(state, false);

    expect(state.isShowingLabels).toBe(false);
  });
});

describe('REQUEST_AVAILABLE_BOARDS', () => {
  expectNotImplemented(mutations.REQUEST_AVAILABLE_BOARDS);
});

describe('RECEIVE_AVAILABLE_BOARDS_SUCCESS', () => {
  expectNotImplemented(mutations.RECEIVE_AVAILABLE_BOARDS_SUCCESS);
});

describe('RECEIVE_AVAILABLE_BOARDS_ERROR', () => {
  expectNotImplemented(mutations.RECEIVE_AVAILABLE_BOARDS_ERROR);
});

describe('REQUEST_RECENT_BOARDS', () => {
  expectNotImplemented(mutations.REQUEST_RECENT_BOARDS);
});

describe('RECEIVE_RECENT_BOARDS_SUCCESS', () => {
  expectNotImplemented(mutations.RECEIVE_RECENT_BOARDS_SUCCESS);
});

describe('RECEIVE_RECENT_BOARDS_ERROR', () => {
  expectNotImplemented(mutations.RECEIVE_RECENT_BOARDS_ERROR);
});

describe('REQUEST_REMOVE_BOARD', () => {
  expectNotImplemented(mutations.REQUEST_REMOVE_BOARD);
});

describe('RECEIVE_REMOVE_BOARD_SUCCESS', () => {
  expectNotImplemented(mutations.RECEIVE_REMOVE_BOARD_SUCCESS);
});

describe('RECEIVE_REMOVE_BOARD_ERROR', () => {
  expectNotImplemented(mutations.RECEIVE_REMOVE_BOARD_ERROR);
});

describe('TOGGLE_PROMOTION_STATE', () => {
  expectNotImplemented(mutations.TOGGLE_PROMOTION_STATE);
});

describe('REQUEST_ISSUES_FOR_EPIC', () => {
  it('sets isLoading epicsFlags in state for epicId to true', () => {
    state = {
      ...state,
      epicsFlags: {
        [epicId]: { isLoading: false },
      },
    };

    mutations.REQUEST_ISSUES_FOR_EPIC(state, epicId);

    expect(state.epicsFlags[epicId].isLoading).toBe(true);
  });
});

describe('RECEIVE_ISSUES_FOR_EPIC_SUCCESS', () => {
  it('sets issuesByListId and issues state for epic issues and loading state to false', () => {
    const listIssues = {
      'gid://gitlab/List/1': [mockIssue.id],
      'gid://gitlab/List/2': [mockIssue2.id],
    };
    const issues = {
      436: mockIssue,
      437: mockIssue2,
    };

    mutations.RECEIVE_ISSUES_FOR_EPIC_SUCCESS(state, {
      listData: listIssues,
      issues,
      epicId,
    });

    expect(state.issuesByListId).toEqual(listIssues);
    expect(state.issues).toEqual(issues);
    expect(state.epicsFlags[epicId].isLoading).toBe(false);
  });
});

describe('RECEIVE_ISSUES_FOR_EPIC_FAILURE', () => {
  it('sets loading state to false for epic and error message', () => {
    mutations.RECEIVE_ISSUES_FOR_EPIC_FAILURE(state, epicId);

    expect(state.error).toEqual('An error occurred while fetching issues. Please reload the page.');
    expect(state.epicsFlags[epicId].isLoading).toBe(false);
  });
});

describe('TOGGLE_EPICS_SWIMLANES', () => {
  it('toggles isShowingEpicsSwimlanes from true to false', () => {
    state = {
      ...state,
      isShowingEpicsSwimlanes: true,
    };

    mutations.TOGGLE_EPICS_SWIMLANES(state);

    expect(state.isShowingEpicsSwimlanes).toBe(false);
  });

  it('toggles isShowingEpicsSwimlanes from false to true', () => {
    state = {
      ...state,
      isShowingEpicsSwimlanes: false,
    };

    mutations.TOGGLE_EPICS_SWIMLANES(state);

    expect(state.isShowingEpicsSwimlanes).toBe(true);
  });

  it('sets epicsSwimlanesFetchInProgress to true', () => {
    state = {
      ...state,
      epicsSwimlanesFetchInProgress: false,
    };

    mutations.TOGGLE_EPICS_SWIMLANES(state);

    expect(state.epicsSwimlanesFetchInProgress).toBe(true);
  });
});

describe('SET_EPICS_SWIMLANES', () => {
  it('set isShowingEpicsSwimlanes and epicsSwimlanesFetchInProgress to true', () => {
    state = {
      ...state,
      isShowingEpicsSwimlanes: false,
      epicsSwimlanesFetchInProgress: false,
    };

    mutations.SET_EPICS_SWIMLANES(state);

    expect(state.isShowingEpicsSwimlanes).toBe(true);
    expect(state.epicsSwimlanesFetchInProgress).toBe(true);
  });
});

describe('RECEIVE_BOARD_LISTS_SUCCESS', () => {
  it('sets epicsSwimlanesFetchInProgress to false and populates boardLists with payload', () => {
    state = {
      ...state,
      epicsSwimlanesFetchInProgress: true,
      boardLists: {},
    };

    mutations.RECEIVE_BOARD_LISTS_SUCCESS(state, initialBoardListsState);

    expect(state.epicsSwimlanesFetchInProgress).toBe(false);
    expect(state.boardLists).toEqual(initialBoardListsState);
  });
});

describe('RECEIVE_SWIMLANES_FAILURE', () => {
  it('sets epicsSwimlanesFetchInProgress to false and sets error message', () => {
    state = {
      ...state,
      epicsSwimlanesFetchInProgress: true,
      error: undefined,
    };

    mutations.RECEIVE_SWIMLANES_FAILURE(state);

    expect(state.epicsSwimlanesFetchInProgress).toBe(false);
    expect(state.error).toEqual(
      'An error occurred while fetching the board swimlanes. Please reload the page.',
    );
  });
});

describe('RECEIVE_FIRST_EPICS_SUCCESS', () => {
  it('populates epics and canAdminEpic with payload', () => {
    state = {
      ...state,
      epics: {},
      canAdminEpic: false,
    };

    mutations.RECEIVE_FIRST_EPICS_SUCCESS(state, { epics: mockEpics, canAdminEpic: true });

    expect(state.epics).toEqual(mockEpics);
    expect(state.canAdminEpic).toEqual(true);
  });

  it('merges epics while avoiding duplicates', () => {
    state = {
      ...state,
      epics: mockEpics,
      canAdminEpic: false,
    };

    mutations.RECEIVE_FIRST_EPICS_SUCCESS(state, mockEpics);

    expect(state.epics).toEqual(mockEpics);
  });
});

describe('RECEIVE_EPICS_SUCCESS', () => {
  it('populates epics with payload', () => {
    state = {
      ...state,
      epics: {},
    };

    mutations.RECEIVE_EPICS_SUCCESS(state, mockEpics);

    expect(state.epics).toEqual(mockEpics);
  });

  it("doesn't add duplicate epics", () => {
    state = {
      ...state,
      epics: mockEpics,
    };

    mutations.RECEIVE_EPICS_SUCCESS(state, mockEpics);

    expect(state.epics).toEqual(mockEpics);
  });
});

describe('RESET_EPICS', () => {
  it('should remove issues from issuesByListId state', () => {
    state = {
      ...state,
      epics: mockEpics,
    };

    mutations.RESET_EPICS(state);

    expect(state.epics).toEqual([]);
  });
});

describe('MOVE_ISSUE', () => {
  beforeEach(() => {
    const listIssues = {
      'gid://gitlab/List/1': [mockIssue.id, mockIssue2.id],
      'gid://gitlab/List/2': [],
    };

    const issues = {
      436: mockIssue,
      437: mockIssue2,
    };

    state = {
      ...state,
      issuesByListId: listIssues,
      issues,
    };
  });

  it('updates issuesByListId, moving issue between lists and updating epic id on issue', () => {
    expect(state.issues['437'].epic.id).toEqual('gid://gitlab/Epic/40');

    mutations.MOVE_ISSUE(state, {
      originalIssue: mockIssue2,
      fromListId: 'gid://gitlab/List/1',
      toListId: 'gid://gitlab/List/2',
      epicId,
    });

    const updatedListIssues = {
      'gid://gitlab/List/1': [mockIssue.id],
      'gid://gitlab/List/2': [mockIssue2.id],
    };

    expect(state.issuesByListId).toEqual(updatedListIssues);
    expect(state.issues['437'].epic.id).toEqual(epicId);
  });

  it('removes epic id from issue when epicId is null', () => {
    expect(state.issues['437'].epic.id).toEqual('gid://gitlab/Epic/40');

    mutations.MOVE_ISSUE(state, {
      originalIssue: mockIssue2,
      fromListId: 'gid://gitlab/List/1',
      toListId: 'gid://gitlab/List/2',
      epicId: null,
    });

    const updatedListIssues = {
      'gid://gitlab/List/1': [mockIssue.id],
      'gid://gitlab/List/2': [mockIssue2.id],
    };

    expect(state.issuesByListId).toEqual(updatedListIssues);
    expect(state.issues['437'].epic).toEqual(null);
  });
});

describe('SET_BOARD_EPIC_USER_PREFERENCES', () => {
  it('should replace userPreferences on the given epic', () => {
    state = {
      ...state,
      epics: mockEpics,
    };

    const epic = mockEpics[0];
    const userPreferences = { collapsed: false };

    mutations.SET_BOARD_EPIC_USER_PREFERENCES(state, { epicId: epic.id, userPreferences });

    expect(state.epics[0].userPreferences).toEqual(userPreferences);
  });
});
