import mutations from 'ee/boards/stores/mutations';
import { mockEpics, mockEpic, mockLists } from '../mock_data';

const initialBoardListsState = {
  'gid://gitlab/List/1': mockLists[0],
  'gid://gitlab/List/2': mockLists[1],
};

let state = {
  boardItemsByListId: {},
  boardItems: {},
  boardLists: initialBoardListsState,
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
      epicsSwimlanesFetchInProgress: {
        epicLanesFetchInProgress: false,
        listItemsFetchInProgress: false,
      },
    };

    mutations.TOGGLE_EPICS_SWIMLANES(state);

    expect(state.epicsSwimlanesFetchInProgress).toEqual({
      epicLanesFetchInProgress: true,
      listItemsFetchInProgress: true,
    });
  });
});

describe('SET_EPICS_SWIMLANES', () => {
  it('set isShowingEpicsSwimlanes and epicsSwimlanesFetchInProgress to true', () => {
    state = {
      ...state,
      isShowingEpicsSwimlanes: false,
      epicsSwimlanesFetchInProgress: {
        epicLanesFetchInProgress: false,
        listItemsFetchInProgress: false,
      },
    };

    mutations.SET_EPICS_SWIMLANES(state);

    expect(state.isShowingEpicsSwimlanes).toBe(true);
    expect(state.epicsSwimlanesFetchInProgress).toEqual({
      epicLanesFetchInProgress: true,
      listItemsFetchInProgress: true,
    });
  });
});

describe('DONE_LOADING_SWIMLANES_ITEMS', () => {
  it('set listItemsFetchInProgress to false', () => {
    state = {
      ...state,
      epicsSwimlanesFetchInProgress: {
        listItemsFetchInProgress: true,
      },
    };

    mutations.DONE_LOADING_SWIMLANES_ITEMS(state);

    expect(state.epicsSwimlanesFetchInProgress.listItemsFetchInProgress).toBe(false);
  });
});

describe('RECEIVE_BOARD_LISTS_SUCCESS', () => {
  it('populates boardLists with payload', () => {
    state = {
      ...state,
      boardLists: {},
    };

    mutations.RECEIVE_BOARD_LISTS_SUCCESS(state, initialBoardListsState);

    expect(state.boardLists).toEqual(initialBoardListsState);
  });
});

describe('RECEIVE_SWIMLANES_FAILURE', () => {
  it('sets epicLanesFetchInProgress to false and sets error message', () => {
    state = {
      ...state,
      epicsSwimlanesFetchInProgress: {
        epicLanesFetchInProgress: true,
      },
      error: undefined,
    };

    mutations.RECEIVE_SWIMLANES_FAILURE(state);

    expect(state.epicsSwimlanesFetchInProgress.epicLanesFetchInProgress).toBe(false);
    expect(state.error).toEqual(
      'An error occurred while fetching the board swimlanes. Please reload the page.',
    );
  });
});

describe('RECEIVE_EPICS_SUCCESS', () => {
  it('populates epics and canAdminEpic with payload', () => {
    state = {
      ...state,
      epics: {},
      canAdminEpic: false,
    };

    mutations.RECEIVE_EPICS_SUCCESS(state, { epics: mockEpics, canAdminEpic: true });

    expect(state.epics).toEqual(mockEpics);
    expect(state.canAdminEpic).toEqual(true);
  });

  it('merges epics while avoiding duplicates', () => {
    state = {
      ...state,
      epics: mockEpics,
      canAdminEpic: false,
    };

    mutations.RECEIVE_EPICS_SUCCESS(state, mockEpics);

    expect(state.epics).toEqual(mockEpics);
  });
});

describe('RESET_EPICS', () => {
  it('should remove issues from boardItemsByListId state', () => {
    state = {
      ...state,
      epics: mockEpics,
    };

    mutations.RESET_EPICS(state);

    expect(state.epics).toEqual([]);
  });
});

describe('MOVE_EPIC', () => {
  it('updates boardItemsByListId, moving epic between lists', () => {
    const listIssues = {
      'gid://gitlab/List/1': [mockEpic.id, mockEpics[1].id],
      'gid://gitlab/List/2': [],
    };

    const epics = {
      1: mockEpic,
      2: mockEpics[1],
    };

    state = {
      ...state,
      boardItemsByListId: listIssues,
      boardLists: initialBoardListsState,
      boardItems: epics,
    };

    mutations.MOVE_EPIC(state, {
      originalEpic: mockEpics[1],
      fromListId: 'gid://gitlab/List/1',
      toListId: 'gid://gitlab/List/2',
    });

    const updatedListEpics = {
      'gid://gitlab/List/1': [mockEpic.id],
      'gid://gitlab/List/2': [mockEpics[1].id],
    };

    expect(state.boardItemsByListId).toEqual(updatedListEpics);
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
