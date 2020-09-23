import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import boardsStoreEE from 'ee/boards/stores/boards_store_ee';
import actions, { gqlClient } from 'ee/boards/stores/actions';
import * as types from 'ee/boards/stores/mutation_types';
import testAction from 'helpers/vuex_action_helper';
import { ListType } from '~/boards/constants';
import { formatListIssues } from '~/boards/boards_util';
import { mockLists, mockIssue, mockEpic } from '../mock_data';

const expectNotImplemented = action => {
  it('is not implemented', () => {
    expect(action).toThrow(new Error('Not implemented!'));
  });
};

let mock;

beforeEach(() => {
  mock = new MockAdapter(axios);
});

afterEach(() => {
  mock.restore();
});

describe('setFilters', () => {
  it('should commit mutation SET_FILTERS, updates epicId with global id', done => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 1 };
    const updatedFilters = { labelName: 'label', epicId: 'gid://gitlab/Epic/1' };

    testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
      done,
    );
  });

  it('should commit mutation SET_FILTERS, updates epicWildcardId', done => {
    const state = {
      filters: {},
    };

    const filters = { labelName: 'label', epicId: 'None' };
    const updatedFilters = { labelName: 'label', epicWildcardId: 'NONE' };

    testAction(
      actions.setFilters,
      filters,
      state,
      [{ type: types.SET_FILTERS, payload: updatedFilters }],
      [],
      done,
    );
  });
});

describe('setShowLabels', () => {
  it('should commit mutation SET_SHOW_LABELS', done => {
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

  it('should call the correct url', () => {
    const maxIssueCount = 0;
    const activeId = 1;

    return actions.updateListWipLimit({ state: { activeId } }, { maxIssueCount }).then(() => {
      expect(axios.put).toHaveBeenCalledWith(
        `${boardsStoreEE.store.state.endpoints.listsEndpoint}/${activeId}`,
        { list: { max_issue_count: maxIssueCount } },
      );
    });
  });
});

describe('showPromotionList', () => {
  it('should dispatch addList action when conditions showPromotion is true', done => {
    const state = {
      endpoints: { fullPath: 'gitlab-org', boardId: '1' },
      boardType: 'group',
      disabled: false,
      boardLists: [{ type: 'backlog' }, { type: 'closed' }],
      showPromotion: true,
    };

    const promotionList = {
      id: 'promotion',
      listType: ListType.promotion,
      title: 'Improve Issue Boards',
      position: 0,
    };

    testAction(
      actions.showPromotionList,
      {},
      state,
      [],
      [{ type: 'addList', payload: promotionList }],
      done,
    );
  });
});

describe('fetchAllBoards', () => {
  expectNotImplemented(actions.fetchAllBoards);
});

describe('fetchRecentBoards', () => {
  expectNotImplemented(actions.fetchRecentBoards);
});

describe('createBoard', () => {
  expectNotImplemented(actions.createBoard);
});

describe('deleteBoard', () => {
  expectNotImplemented(actions.deleteBoard);
});

describe('updateIssueWeight', () => {
  expectNotImplemented(actions.updateIssueWeight);
});

describe('togglePromotionState', () => {
  expectNotImplemented(actions.updateIssueWeight);
});

describe('fetchIssuesForEpic', () => {
  const listId = mockLists[0].id;
  const epicId = mockEpic.id;

  const state = {
    endpoints: {
      fullPath: 'gitlab-org',
      boardId: 1,
    },
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
                  nodes: [mockIssue],
                },
              },
            ],
          },
        },
      },
    },
  };

  const formattedIssues = formatListIssues(queryResponse.data.group.board.lists);

  it('should commit mutations REQUEST_ISSUES_FOR_EPIC and RECEIVE_ISSUES_FOR_LIST_SUCCESS on success', done => {
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

  it('should commit mutations REQUEST_ISSUES_FOR_EPIC and RECEIVE_ISSUES_FOR_LIST_FAILURE on failure', done => {
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
    const state = {
      isShowingEpicsSwimlanes: false,
      endpoints: {
        fullPath: 'gitlab-org',
        boardId: 1,
      },
    };

    return testAction(
      actions.toggleEpicSwimlanes,
      null,
      state,
      [{ type: types.TOGGLE_EPICS_SWIMLANES }],
      [],
    );
  });
});
