import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { GroupByParamType } from 'ee/boards/constants';
import actions, { gqlClient } from 'ee/boards/stores/actions';
import boardsStoreEE from 'ee/boards/stores/boards_store_ee';
import * as types from 'ee/boards/stores/mutation_types';
import { TEST_HOST } from 'helpers/test_constants';
import testAction from 'helpers/vuex_action_helper';
import { formatListIssues } from '~/boards/boards_util';
import * as typesCE from '~/boards/stores/mutation_types';
import * as commonUtils from '~/lib/utils/common_utils';
import { mergeUrlParams, removeParams } from '~/lib/utils/url_utility';
import { mockLists, mockIssue, mockIssue2, mockEpic, rawIssue } from '../mock_data';

const expectNotImplemented = (action) => {
  it('is not implemented', () => {
    expect(action).toThrow(new Error('Not implemented!'));
  });
};

let mock;

beforeEach(() => {
  mock = new MockAdapter(axios);
  window.gon = { features: {} };
  jest.spyOn(commonUtils, 'historyPushState');
});

afterEach(() => {
  mock.restore();
});

describe('setFilters', () => {
  it('should commit mutation SET_FILTERS, updates epicId with global id', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 1 };
    const updatedFilters = { labelName: 'label', epicId: 'gid://gitlab/Epic/1' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
    );
  });

  it('should commit mutation SET_FILTERS, updates epicWildcardId', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 'None' };
    const updatedFilters = { labelName: 'label', epicWildcardId: 'NONE' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
    );
  });

  it('should commit mutation SET_FILTERS, updates iterationWildcardId', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', iterationId: 'None' };
    const updatedFilters = { labelName: 'label', iterationWildcardId: 'NONE' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
    );
  });

  it('should commit mutation SET_FILTERS, dispatches setEpicSwimlanes action if filters contain groupBy epic', () => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 1, groupBy: 'epic' };
    const updatedFilters = { labelName: 'label', epicId: 'gid://gitlab/Epic/1' };

    return testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [{ type: 'setEpicSwimlanes' }],
    );
  });
});

describe('performSearch', () => {
  it('should dispatch setFilters action', (done) => {
    testAction(actions.performSearch, {}, {}, [], [{ type: 'setFilters', payload: {} }], done);
  });

  it('should dispatch setFilters, fetchLists and resetIssues action when graphqlBoardLists FF is on', async () => {
    window.gon = { features: { graphqlBoardLists: true } };
    const getters = { isSwimlanesOn: false };

    await testAction({
      action: actions.performSearch,
      state: { ...getters },
      expectedActions: [
        { type: 'setFilters', payload: {} },
        { type: 'fetchLists' },
        { type: 'resetIssues' },
      ],
    });
  });

  it('should dispatch setFilters, resetEpics, fetchEpicsSwimlanes and resetIssues action when isSwimlanesOn', async () => {
    const getters = { isSwimlanesOn: true };
    await testAction({
      action: actions.performSearch,
      state: { isShowingEpicsSwimlanes: true, ...getters },
      expectedActions: [
        { type: 'setFilters', payload: {} },
        { type: 'resetEpics' },
        { type: 'resetIssues' },
        { type: 'fetchEpicsSwimlanes', payload: {} },
      ],
    });
  });
});

describe('fetchEpicsSwimlanes', () => {
  const state = {
    fullPath: 'gitlab-org',
    boardId: 1,
    filterParams: {},
    boardType: 'group',
  };

  const queryResponse = {
    data: {
      group: {
        board: {
          epics: {
            edges: [{ node: mockEpic }],
            pageInfo: {},
          },
        },
      },
    },
  };

  it('should commit mutation RECEIVE_EPICS_SUCCESS and UPDATE_CACHED_EPICS on success without lists', (done) => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(queryResponse);

    testAction(
      actions.fetchEpicsSwimlanes,
      { withLists: false },
      state,
      [
        {
          type: types.RECEIVE_EPICS_SUCCESS,
          payload: [mockEpic],
        },
        {
          type: types.UPDATE_CACHED_EPICS,
          payload: [mockEpic],
        },
      ],
      [],
      done,
    );
  });

  it('should commit mutation RECEIVE_SWIMLANES_FAILURE on failure', (done) => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(Promise.reject());

    testAction(
      actions.fetchEpicsSwimlanes,
      {},
      state,
      [{ type: types.RECEIVE_SWIMLANES_FAILURE }],
      [],
      done,
    );
  });

  it('should dispatch fetchEpicsSwimlanes when page info hasNextPage', (done) => {
    const queryResponseWithNextPage = {
      data: {
        group: {
          board: {
            epics: {
              edges: [{ node: mockEpic }],
              pageInfo: {
                hasNextPage: true,
                endCursor: 'ENDCURSOR',
              },
            },
          },
        },
      },
    };
    jest.spyOn(gqlClient, 'query').mockResolvedValue(queryResponseWithNextPage);

    testAction(
      actions.fetchEpicsSwimlanes,
      { withLists: false },
      state,
      [
        {
          type: types.RECEIVE_EPICS_SUCCESS,
          payload: [mockEpic],
        },
        {
          type: types.UPDATE_CACHED_EPICS,
          payload: [mockEpic],
        },
      ],
      [
        {
          type: 'fetchEpicsSwimlanes',
          payload: { withLists: false, endCursor: 'ENDCURSOR' },
        },
      ],
      done,
    );
  });
});

describe('updateBoardEpicUserPreferences', () => {
  const state = {
    boardId: 1,
  };

  const queryResponse = (collapsed = false) => ({
    data: {
      updateBoardEpicUserPreferences: {
        errors: [],
        epicUserPreferences: { collapsed },
      },
    },
  });

  it('should send mutation', (done) => {
    const collapsed = true;
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue(queryResponse(collapsed));

    testAction(
      actions.updateBoardEpicUserPreferences,
      { epicId: mockEpic.id, collapsed },
      state,
      [
        {
          payload: {
            epicId: mockEpic.id,
            userPreferences: {
              collapsed,
            },
          },
          type: types.SET_BOARD_EPIC_USER_PREFERENCES,
        },
      ],
      [],
      done,
    );
  });
});

describe('setShowLabels', () => {
  it('should commit mutation SET_SHOW_LABELS', (done) => {
    const state = {
      isShowingLabels: true,
    };

    testAction(
      actions.setShowLabels,
      false,
      state,
      [{ type: types.SET_SHOW_LABELS, payload: false }],
      [],
      done,
    );
  });
});

describe('updateListWipLimit', () => {
  let storeMock;
  const getters = { shouldUseGraphQL: false };

  beforeEach(() => {
    storeMock = {
      state: { endpoints: { listsEndpoint: '/test' } },
      create: () => {},
      setCurrentBoard: () => {},
    };

    boardsStoreEE.initEESpecific(storeMock);
    jest.mock('axios');
    axios.put = jest.fn();
    axios.put.mockResolvedValue({ data: {} });
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('axios - should call the correct url', () => {
    const maxIssueCount = 0;
    const activeId = 1;

    return actions
      .updateListWipLimit({ state: { activeId }, getters }, { maxIssueCount, listId: activeId })
      .then(() => {
        expect(axios.put).toHaveBeenCalledWith(
          `${boardsStoreEE.store.state.endpoints.listsEndpoint}/${activeId}`,
          {
            list: { max_issue_count: maxIssueCount },
          },
        );
      });
  });

  it('graphql - commit UPDATE_LIST_SUCCESS mutation on success', () => {
    const maxIssueCount = 0;
    const activeId = 1;
    getters.shouldUseGraphQL = true;
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        boardListUpdateLimitMetrics: {
          list: {
            id: activeId,
          },
          errors: [],
        },
      },
    });

    return testAction(
      actions.updateListWipLimit,
      { maxIssueCount, listId: activeId },
      { isShowingEpicsSwimlanes: true, ...getters },
      [
        {
          type: types.UPDATE_LIST_SUCCESS,
          payload: {
            listId: activeId,
            list: expect.objectContaining({
              id: activeId,
            }),
          },
        },
      ],
      [],
    );
  });

  it('graphql - commit UPDATE_LIST_FAILURE mutation on failure', () => {
    const maxIssueCount = 0;
    const activeId = 1;
    getters.shouldUseGraphQL = true;
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue(Promise.reject());

    return testAction(
      actions.updateListWipLimit,
      { maxIssueCount, listId: activeId },
      { isShowingEpicsSwimlanes: true, ...getters },
      [{ type: types.UPDATE_LIST_FAILURE }],
      [],
    );
  });
});

describe('fetchAllBoards', () => {
  expectNotImplemented(actions.fetchAllBoards);
});

describe('fetchRecentBoards', () => {
  expectNotImplemented(actions.fetchRecentBoards);
});

describe('deleteBoard', () => {
  expectNotImplemented(actions.deleteBoard);
});

describe('updateIssueWeight', () => {
  expectNotImplemented(actions.updateIssueWeight);
});

describe('fetchIssuesForEpic', () => {
  const listId = mockLists[0].id;
  const epicId = mockEpic.id;

  const state = {
    fullPath: 'gitlab-org',
    boardId: 1,
    filterParams: {},
    boardType: 'group',
  };

  const queryResponse = {
    data: {
      group: {
        board: {
          lists: {
            nodes: [
              {
                id: listId,
                issues: {
                  edges: [{ node: [mockIssue] }],
                },
              },
            ],
          },
        },
      },
    },
  };

  const formattedIssues = formatListIssues(queryResponse.data.group.board.lists);

  it('should commit mutations REQUEST_ISSUES_FOR_EPIC and RECEIVE_ISSUES_FOR_LIST_SUCCESS on success', (done) => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(queryResponse);

    testAction(
      actions.fetchIssuesForEpic,
      epicId,
      state,
      [
        { type: types.REQUEST_ISSUES_FOR_EPIC, payload: epicId },
        { type: types.RECEIVE_ISSUES_FOR_EPIC_SUCCESS, payload: { ...formattedIssues, epicId } },
      ],
      [],
      done,
    );
  });

  it('should commit mutations REQUEST_ISSUES_FOR_EPIC and RECEIVE_ISSUES_FOR_LIST_FAILURE on failure', (done) => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue(Promise.reject());

    testAction(
      actions.fetchIssuesForEpic,
      epicId,
      state,
      [
        { type: types.REQUEST_ISSUES_FOR_EPIC, payload: epicId },
        { type: types.RECEIVE_ISSUES_FOR_EPIC_FAILURE, payload: epicId },
      ],
      [],
      done,
    );
  });
});

describe('toggleEpicSwimlanes', () => {
  it('should commit mutation TOGGLE_EPICS_SWIMLANES', () => {
    const startURl = `${TEST_HOST}/groups/gitlab-org/-/boards/1?group_by=epic`;
    global.jsdom.reconfigure({
      url: startURl,
    });

    const state = {
      isShowingEpicsSwimlanes: false,
      fullPath: 'gitlab-org',
      boardId: 1,
    };

    return testAction(
      actions.toggleEpicSwimlanes,
      null,
      state,
      [{ type: types.TOGGLE_EPICS_SWIMLANES }],
      [],
      () => {
        expect(commonUtils.historyPushState).toHaveBeenCalledWith(
          removeParams(['group_by']),
          startURl,
          true,
        );
        expect(global.window.location.href).toBe(`${TEST_HOST}/groups/gitlab-org/-/boards/1`);
      },
    );
  });

  it('should dispatch fetchEpicsSwimlanes action when isShowingEpicsSwimlanes is true', () => {
    global.jsdom.reconfigure({
      url: `${TEST_HOST}/groups/gitlab-org/-/boards/1`,
    });

    jest.spyOn(gqlClient, 'query').mockResolvedValue({});

    const state = {
      isShowingEpicsSwimlanes: true,
      fullPath: 'gitlab-org',
      boardId: 1,
    };

    return testAction(
      actions.toggleEpicSwimlanes,
      null,
      state,
      [{ type: types.TOGGLE_EPICS_SWIMLANES }],
      [{ type: 'fetchEpicsSwimlanes', payload: {} }],
      () => {
        expect(commonUtils.historyPushState).toHaveBeenCalledWith(
          mergeUrlParams({ group_by: GroupByParamType.epic }, window.location.href),
        );
        expect(global.window.location.href).toBe(
          `${TEST_HOST}/groups/gitlab-org/-/boards/1?group_by=epic`,
        );
      },
    );
  });
});

describe('setEpicSwimlanes', () => {
  it('should commit mutation SET_EPICS_SWIMLANES and dispatch fetchEpicsSwimlanes action', () => {
    jest.spyOn(gqlClient, 'query').mockResolvedValue({});

    return testAction(
      actions.setEpicSwimlanes,
      null,
      {},
      [{ type: types.SET_EPICS_SWIMLANES }],
      [{ type: 'fetchEpicsSwimlanes', payload: {} }],
    );
  });
});

describe('resetEpics', () => {
  it('commits RESET_EPICS mutation', () => {
    return testAction(actions.resetEpics, {}, {}, [{ type: types.RESET_EPICS }], []);
  });
});

describe('fetchEpicForActiveIssue', () => {
  const assignedEpic = {
    id: mockIssue.epic.id,
    iid: mockIssue.epic.iid,
  };

  describe("when active issue doesn't have an assigned epic", () => {
    const getters = { activeIssue: { ...mockIssue, epic: null } };

    it('should not fetch any epic', async () => {
      await testAction(actions.fetchEpicForActiveIssue, undefined, { ...getters }, [], []);
    });
  });

  describe('when the assigned epic for active issue is found in state.epicsCacheById', () => {
    const getters = { activeIssue: { ...mockIssue, epic: assignedEpic } };
    const state = { epicsCacheById: { [assignedEpic.id]: assignedEpic } };

    it('should not fetch any epic', async () => {
      await testAction(
        actions.fetchEpicForActiveIssue,
        undefined,
        { ...state, ...getters },
        [],
        [],
      );
    });
  });

  describe('when fetching fails', () => {
    const getters = { activeIssue: { ...mockIssue, epic: assignedEpic } };
    const state = { epicsCacheById: {} };

    it('should not commit UPDATE_CACHED_EPICS mutation and should throw an error', () => {
      const mockError = new Error('mayday');
      jest.spyOn(gqlClient, 'query').mockRejectedValue(mockError);

      return testAction(
        actions.fetchEpicForActiveIssue,
        undefined,
        { ...state, ...getters },
        [
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: true,
          },
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: false,
          },
        ],
        [],
      ).catch((e) => {
        expect(e).toEqual(mockError);
      });
    });
  });

  describe("when the assigned epic for active issue isn't found in state.epicsCacheById", () => {
    const getters = { activeIssue: { ...mockIssue, epic: assignedEpic } };
    const state = { epicsCacheById: {} };

    it('should commit mutation SET_EPIC_FETCH_IN_PROGRESS before and after committing mutation UPDATE_CACHED_EPICS', async () => {
      jest.spyOn(gqlClient, 'query').mockResolvedValue({ data: { group: { epic: mockEpic } } });

      await testAction(
        actions.fetchEpicForActiveIssue,
        undefined,
        { ...state, ...getters },
        [
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: true,
          },
          {
            type: types.UPDATE_CACHED_EPICS,
            payload: [mockEpic],
          },
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: false,
          },
        ],
        [],
      );
    });
  });
});

describe('setActiveIssueEpic', () => {
  const state = {
    epics: [{ id: 'gid://gitlab/Epic/422', iid: 99, title: 'existing epic' }],
  };
  const getters = { activeIssue: { ...mockIssue, projectPath: 'h/b' } };
  const epicWithData = {
    id: 'gid://gitlab/Epic/42',
    iid: 1,
    title: 'Epic title',
  };

  describe('when the updated issue has an assigned epic', () => {
    it('should commit mutation RECEIVE_FIRST_EPICS_SUCCESS, UPDATE_CACHED_EPICS and UPDATE_ISSUE_BY_ID on success', async () => {
      jest
        .spyOn(gqlClient, 'mutate')
        .mockResolvedValue({ data: { issueSetEpic: { issue: { epic: epicWithData } } } });

      await testAction(
        actions.setActiveIssueEpic,
        epicWithData.id,
        { ...state, ...getters },
        [
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: true,
          },
          {
            type: types.RECEIVE_FIRST_EPICS_SUCCESS,
            payload: { epics: [epicWithData, ...state.epics] },
          },
          {
            type: types.UPDATE_CACHED_EPICS,
            payload: [epicWithData],
          },
          {
            type: typesCE.UPDATE_ISSUE_BY_ID,
            payload: {
              issueId: mockIssue.id,
              prop: 'epic',
              value: { id: epicWithData.id, iid: epicWithData.iid },
            },
          },
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: false,
          },
        ],
        [],
      );
    });
  });

  describe('when the updated issue does not have an epic (unassigned)', () => {
    it('should only commit UPDATE_ISSUE_BY_ID on success', async () => {
      jest
        .spyOn(gqlClient, 'mutate')
        .mockResolvedValue({ data: { issueSetEpic: { issue: { epic: null } } } });

      await testAction(
        actions.setActiveIssueEpic,
        null,
        { ...state, ...getters },
        [
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: true,
          },
          {
            type: typesCE.UPDATE_ISSUE_BY_ID,
            payload: { issueId: mockIssue.id, prop: 'epic', value: null },
          },
          {
            type: types.SET_EPIC_FETCH_IN_PROGRESS,
            payload: false,
          },
        ],
        [],
      );
    });
  });

  it('throws error if fails', async () => {
    jest
      .spyOn(gqlClient, 'mutate')
      .mockResolvedValue({ data: { issueSetEpic: { errors: ['failed mutation'] } } });

    await expect(actions.setActiveIssueEpic({ getters }, epicWithData.id)).rejects.toThrow(Error);
  });
});

describe('setActiveIssueWeight', () => {
  const state = { issues: { [mockIssue.id]: mockIssue } };
  const getters = { activeIssue: mockIssue };
  const testWeight = mockIssue.weight + 1;
  const input = {
    weight: testWeight,
    projectPath: 'h/b',
  };

  it('should commit weight after setting the issue', (done) => {
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        issueSetWeight: {
          issue: {
            weight: testWeight,
          },
          errors: [],
        },
      },
    });

    const payload = {
      issueId: getters.activeIssue.id,
      prop: 'weight',
      value: testWeight,
    };

    testAction(
      actions.setActiveIssueWeight,
      input,
      { ...state, ...getters },
      [
        {
          type: typesCE.UPDATE_ISSUE_BY_ID,
          payload,
        },
      ],
      [],
      done,
    );
  });

  it('throws error if fails', async () => {
    jest
      .spyOn(gqlClient, 'mutate')
      .mockResolvedValue({ data: { issueSetWeight: { errors: ['failed mutation'] } } });

    await expect(actions.setActiveIssueWeight({ getters }, input)).rejects.toThrow(Error);
  });
});

describe('moveIssue', () => {
  const epicId = 'gid://gitlab/Epic/1';

  const listIssues = {
    'gid://gitlab/List/1': [436, 437],
    'gid://gitlab/List/2': [],
  };

  const issues = {
    436: mockIssue,
    437: mockIssue2,
  };

  const state = {
    fullPath: 'gitlab-org',
    boardId: 1,
    boardType: 'group',
    disabled: false,
    boardLists: mockLists,
    issuesByListId: listIssues,
    issues,
  };

  it('should commit MOVE_ISSUE mutation and MOVE_ISSUE_SUCCESS mutation when successful', (done) => {
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        issueMoveList: {
          issue: rawIssue,
          errors: [],
        },
      },
    });

    testAction(
      actions.moveIssue,
      {
        issueId: '436',
        issueIid: mockIssue.iid,
        issuePath: mockIssue.referencePath,
        fromListId: 'gid://gitlab/List/1',
        toListId: 'gid://gitlab/List/2',
        epicId,
      },
      state,
      [
        {
          type: types.MOVE_ISSUE,
          payload: {
            originalIssue: mockIssue,
            fromListId: 'gid://gitlab/List/1',
            toListId: 'gid://gitlab/List/2',
            epicId,
          },
        },
        {
          type: types.MOVE_ISSUE_SUCCESS,
          payload: { issue: rawIssue },
        },
      ],
      [],
      done,
    );
  });

  it('should commit MOVE_ISSUE mutation and MOVE_ISSUE_FAILURE mutation when unsuccessful', (done) => {
    jest.spyOn(gqlClient, 'mutate').mockResolvedValue({
      data: {
        issueMoveList: {
          issue: {},
          errors: [{ foo: 'bar' }],
        },
      },
    });

    testAction(
      actions.moveIssue,
      {
        issueId: '436',
        issueIid: mockIssue.iid,
        issuePath: mockIssue.referencePath,
        fromListId: 'gid://gitlab/List/1',
        toListId: 'gid://gitlab/List/2',
        epicId,
      },
      state,
      [
        {
          type: types.MOVE_ISSUE,
          payload: {
            originalIssue: mockIssue,
            fromListId: 'gid://gitlab/List/1',
            toListId: 'gid://gitlab/List/2',
            epicId,
          },
        },
        {
          type: types.MOVE_ISSUE_FAILURE,
          payload: {
            originalIssue: mockIssue,
            fromListId: 'gid://gitlab/List/1',
            toListId: 'gid://gitlab/List/2',
            originalIndex: 0,
          },
        },
      ],
      [],
      done,
    );
  });
});
