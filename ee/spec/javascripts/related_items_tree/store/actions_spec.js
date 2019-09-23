import MockAdapter from 'axios-mock-adapter';

import createDefaultState from 'ee/related_items_tree/store/state';
import * as actions from 'ee/related_items_tree/store/actions';
import * as types from 'ee/related_items_tree/store/mutation_types';

import * as epicUtils from 'ee/related_items_tree/utils/epic_utils';
import {
  ChildType,
  ChildState,
  ActionType,
  PathIdSeparator,
} from 'ee/related_items_tree/constants';

import axios from '~/lib/utils/axios_utils';
import testAction from 'spec/helpers/vuex_action_helper';

import {
  mockInitialConfig,
  mockParentItem,
  mockQueryResponse,
  mockEpicTreeReorderInput,
  mockReorderMutationResponse,
  mockEpics,
  mockIssues,
  mockEpic1,
} from '../mock_data';

describe('RelatedItemTree', () => {
  describe('store', () => {
    describe('actions', () => {
      let state;
      const mockItems = mockEpics.map(item =>
        epicUtils.formatChildItem(Object.assign(item, { type: ChildType.Epic })),
      );

      beforeEach(() => {
        state = createDefaultState();
      });

      describe('setInitialConfig', () => {
        it('should set initial config on state', done => {
          testAction(
            actions.setInitialConfig,
            mockInitialConfig,
            {},
            [{ type: types.SET_INITIAL_CONFIG, payload: mockInitialConfig }],
            [],
            done,
          );
        });
      });

      describe('setInitialParentItem', () => {
        it('should set initial parentItem on state', done => {
          testAction(
            actions.setInitialParentItem,
            mockParentItem,
            {},
            [{ type: types.SET_INITIAL_PARENT_ITEM, payload: mockParentItem }],
            [],
            done,
          );
        });
      });

      describe('setChildrenCount', () => {
        const mockEpicsWithType = mockEpics.map(item =>
          Object.assign({}, item, {
            type: ChildType.Epic,
          }),
        );

        const mockIssuesWithType = mockIssues.map(item =>
          Object.assign({}, item, {
            type: ChildType.Issue,
          }),
        );

        const mockChildren = [...mockEpicsWithType, ...mockIssuesWithType];

        it('should set `epicsCount` and `issuesCount`, by incrementing it, on state', done => {
          testAction(
            actions.setChildrenCount,
            { children: mockChildren, isRemoved: false },
            {},
            [
              {
                type: types.SET_CHILDREN_COUNT,
                payload: { epicsCount: mockEpics.length, issuesCount: mockIssues.length },
              },
            ],
            [],
            done,
          );
        });

        it('should set `epicsCount` and `issuesCount`, by decrementing it, on state', done => {
          testAction(
            actions.setChildrenCount,
            { children: mockChildren, isRemoved: true },
            {
              epicsCount: mockEpics.length,
              issuesCount: mockIssues.length,
            },
            [
              {
                type: types.SET_CHILDREN_COUNT,
                payload: { epicsCount: 0, issuesCount: 0 },
              },
            ],
            [],
            done,
          );
        });
      });

      describe('expandItem', () => {
        it('should set `itemExpanded` to true on state.childrenFlags', done => {
          testAction(
            actions.expandItem,
            {},
            {},
            [{ type: types.EXPAND_ITEM, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('collapseItem', () => {
        it('should set `itemExpanded` to false on state.childrenFlags', done => {
          testAction(
            actions.collapseItem,
            {},
            {},
            [{ type: types.COLLAPSE_ITEM, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('setItemChildren', () => {
        const mockPayload = {
          children: ['foo'],
          parentItem: mockParentItem,
          isSubItem: false,
          append: false,
        };

        it('should set provided `children` values on state.children with provided parentItem.reference key', done => {
          testAction(
            actions.setItemChildren,
            mockPayload,
            {},
            [
              {
                type: types.SET_ITEM_CHILDREN,
                payload: mockPayload,
              },
            ],
            [
              {
                type: 'setChildrenCount',
                payload: { children: mockPayload.children },
              },
            ],
            done,
          );
        });

        it('should set provided `children` values on state.children with provided parentItem.reference key and also dispatch action `expandItem` when isSubItem param is true', done => {
          mockPayload.isSubItem = true;

          testAction(
            actions.setItemChildren,
            mockPayload,
            {},
            [
              {
                type: types.SET_ITEM_CHILDREN,
                payload: mockPayload,
              },
            ],
            [
              {
                type: 'setChildrenCount',
                payload: { children: mockPayload.children },
              },
              {
                type: 'expandItem',
                payload: { parentItem: mockPayload.parentItem },
              },
            ],
            done,
          );
        });
      });

      describe('setItemChildrenFlags', () => {
        it('should set `state.childrenFlags` for every item in provided children param', done => {
          testAction(
            actions.setItemChildrenFlags,
            { children: [{ reference: '&1' }] },
            {},
            [{ type: types.SET_ITEM_CHILDREN_FLAGS, payload: { children: [{ reference: '&1' }] } }],
            [],
            done,
          );
        });
      });

      describe('setEpicPageInfo', () => {
        it('should set `epicEndCursor` and `hasMoreEpics` to `state.childrenFlags`', done => {
          const { pageInfo } = mockQueryResponse.data.group.epic.children;

          testAction(
            actions.setEpicPageInfo,
            { parentItem: mockParentItem, pageInfo },
            {},
            [
              {
                type: types.SET_EPIC_PAGE_INFO,
                payload: { parentItem: mockParentItem, pageInfo },
              },
            ],
            [],
            done,
          );
        });
      });

      describe('setIssuePageInfo', () => {
        it('should set `issueEndCursor` and `hasMoreIssues` to `state.childrenFlags`', done => {
          const { pageInfo } = mockQueryResponse.data.group.epic.issues;

          testAction(
            actions.setIssuePageInfo,
            { parentItem: mockParentItem, pageInfo },
            {},
            [
              {
                type: types.SET_ISSUE_PAGE_INFO,
                payload: { parentItem: mockParentItem, pageInfo },
              },
            ],
            [],
            done,
          );
        });
      });

      describe('requestItems', () => {
        it('should set `state.itemsFetchInProgress` to true', done => {
          testAction(
            actions.requestItems,
            {},
            {},
            [{ type: types.REQUEST_ITEMS, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('receiveItemsSuccess', () => {
        it('should set `state.itemsFetchInProgress` to false', done => {
          testAction(
            actions.receiveItemsSuccess,
            {},
            {},
            [{ type: types.RECEIVE_ITEMS_SUCCESS, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('receiveItemsFailure', () => {
        beforeEach(() => {
          setFixtures('<div class="flash-container"></div>');
        });

        it('should set `state.itemsFetchInProgress` to false', done => {
          testAction(
            actions.receiveItemsFailure,
            {},
            {},
            [{ type: types.RECEIVE_ITEMS_FAILURE, payload: {} }],
            [],
            done,
          );
        });

        it('should show flash error with message "Something went wrong while fetching child epics."', () => {
          const message = 'Something went wrong while fetching child epics.';
          actions.receiveItemsFailure(
            {
              commit: () => {},
            },
            {},
          );

          expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
            message,
          );
        });
      });

      describe('fetchItems', () => {
        it('should dispatch `requestItems` action', done => {
          testAction(
            actions.fetchItems,
            { parentItem: mockParentItem, isSubItem: false },
            {},
            [],
            [
              {
                type: 'requestItems',
                payload: { parentItem: mockParentItem, isSubItem: false },
              },
            ],
            done,
          );
        });

        it('should dispatch `receiveItemsSuccess`, `setItemChildren`, `setItemChildrenFlags`, `setEpicPageInfo` and `setIssuePageInfo` on request success', done => {
          spyOn(epicUtils.gqClient, 'query').and.returnValue(
            Promise.resolve({
              data: mockQueryResponse.data,
            }),
          );

          const children = epicUtils.processQueryResponse(mockQueryResponse.data.group);
          const epicPageInfo = mockQueryResponse.data.group.epic.children.pageInfo;
          const issuesPageInfo = mockQueryResponse.data.group.epic.issues.pageInfo;

          testAction(
            actions.fetchItems,
            { parentItem: mockParentItem, isSubItem: false },
            {},
            [],
            [
              {
                type: 'requestItems',
                payload: { parentItem: mockParentItem, isSubItem: false },
              },
              {
                type: 'receiveItemsSuccess',
                payload: {
                  parentItem: mockParentItem,
                  isSubItem: false,
                  children,
                },
              },
              {
                type: 'setItemChildren',
                payload: {
                  parentItem: mockParentItem,
                  isSubItem: false,
                  children,
                },
              },
              {
                type: 'setItemChildrenFlags',
                payload: {
                  isSubItem: false,
                  children,
                },
              },
              {
                type: 'setEpicPageInfo',
                payload: {
                  parentItem: mockParentItem,
                  pageInfo: epicPageInfo,
                },
              },
              {
                type: 'setIssuePageInfo',
                payload: {
                  parentItem: mockParentItem,
                  pageInfo: issuesPageInfo,
                },
              },
            ],
            done,
          );
        });

        it('should dispatch `receiveItemsFailure` on request failure', done => {
          spyOn(epicUtils.gqClient, 'query').and.returnValue(Promise.reject());

          testAction(
            actions.fetchItems,
            { parentItem: mockParentItem, isSubItem: false },
            {},
            [],
            [
              {
                type: 'requestItems',
                payload: { parentItem: mockParentItem, isSubItem: false },
              },
              {
                type: 'receiveItemsFailure',
                payload: {
                  parentItem: mockParentItem,
                  isSubItem: false,
                },
              },
            ],
            done,
          );
        });
      });

      describe('receiveNextPageItemsFailure', () => {
        beforeEach(() => {
          setFixtures('<div class="flash-container"></div>');
        });

        it('should show flash error with message "Something went wrong while fetching child epics."', () => {
          const message = 'Something went wrong while fetching child epics.';
          actions.receiveNextPageItemsFailure(
            {
              commit: () => {},
            },
            {},
          );

          expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
            message,
          );
        });
      });

      describe('fetchNextPageItems', () => {
        it('should dispatch `setItemChildren`, `setItemChildrenFlags`, `setEpicPageInfo` and `setIssuePageInfo` on request success', done => {
          spyOn(epicUtils.gqClient, 'query').and.returnValue(
            Promise.resolve({
              data: mockQueryResponse.data,
            }),
          );

          const epicPageInfo = mockQueryResponse.data.group.epic.children.pageInfo;
          const issuesPageInfo = mockQueryResponse.data.group.epic.issues.pageInfo;

          testAction(
            actions.fetchNextPageItems,
            { parentItem: mockParentItem, isSubItem: false },
            { childrenFlags: { 'gitlab-org&1': {} } },
            [],
            [
              {
                type: 'setItemChildren',
                payload: {
                  parentItem: mockParentItem,
                  isSubItem: false,
                  append: true,
                  children: [],
                },
              },
              {
                type: 'setItemChildrenFlags',
                payload: {
                  isSubItem: false,
                  children: [],
                },
              },
              {
                type: 'setEpicPageInfo',
                payload: {
                  parentItem: mockParentItem,
                  pageInfo: epicPageInfo,
                },
              },
              {
                type: 'setIssuePageInfo',
                payload: {
                  parentItem: mockParentItem,
                  pageInfo: issuesPageInfo,
                },
              },
            ],
            done,
          );
        });

        it('should dispatch `receiveNextPageItemsFailure` on request failure', done => {
          spyOn(epicUtils.gqClient, 'query').and.returnValue(Promise.reject());

          testAction(
            actions.fetchNextPageItems,
            { parentItem: mockParentItem, isSubItem: false },
            { childrenFlags: { 'gitlab-org&1': {} } },
            [],
            [
              {
                type: 'receiveNextPageItemsFailure',
                payload: {
                  parentItem: mockParentItem,
                },
              },
            ],
            done,
          );
        });
      });

      describe('toggleItem', () => {
        const data = {
          parentItem: {
            reference: '&1',
          },
        };

        it('should dispatch `fetchItems` when a parent item is not expanded and does not have children present in state', done => {
          state.childrenFlags[data.parentItem.reference] = {
            itemExpanded: false,
          };

          testAction(
            actions.toggleItem,
            data,
            state,
            [],
            [
              {
                type: 'fetchItems',
                payload: { parentItem: data.parentItem, isSubItem: true },
              },
            ],
            done,
          );
        });

        it('should dispatch `expandItem` when a parent item is not expanded but does have children present in state', done => {
          state.childrenFlags[data.parentItem.reference] = {
            itemExpanded: false,
          };
          state.children[data.parentItem.reference] = ['foo'];

          testAction(
            actions.toggleItem,
            data,
            state,
            [],
            [
              {
                type: 'expandItem',
                payload: { parentItem: data.parentItem },
              },
            ],
            done,
          );
        });

        it('should dispatch `collapseItem` when a parent item is expanded', done => {
          state.childrenFlags[data.parentItem.reference] = {
            itemExpanded: true,
          };

          testAction(
            actions.toggleItem,
            data,
            state,
            [],
            [
              {
                type: 'collapseItem',
                payload: { parentItem: data.parentItem },
              },
            ],
            done,
          );
        });
      });

      describe('setRemoveItemModalProps', () => {
        it('should set values on `state.removeItemModalProps` for initializing modal', done => {
          testAction(
            actions.setRemoveItemModalProps,
            {},
            {},
            [{ type: types.SET_REMOVE_ITEM_MODAL_PROPS, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('requestRemoveItem', () => {
        it('should set `state.childrenFlags[ref].itemRemoveInProgress` to true', done => {
          testAction(
            actions.requestRemoveItem,
            {},
            {},
            [{ type: types.REQUEST_REMOVE_ITEM, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('receiveRemoveItemSuccess', () => {
        it('should set `state.childrenFlags[ref].itemRemoveInProgress` to false', done => {
          testAction(
            actions.receiveRemoveItemSuccess,
            {},
            {},
            [{ type: types.RECEIVE_REMOVE_ITEM_SUCCESS, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('receiveRemoveItemFailure', () => {
        beforeEach(() => {
          setFixtures('<div class="flash-container"></div>');
        });

        it('should set `state.childrenFlags[ref].itemRemoveInProgress` to false', done => {
          testAction(
            actions.receiveRemoveItemFailure,
            { item: { type: ChildType.Epic } },
            {},
            [
              {
                type: types.RECEIVE_REMOVE_ITEM_FAILURE,
                payload: { type: ChildType.Epic },
              },
            ],
            [],
            done,
          );
        });

        it('should show flash error with message "An error occurred while removing epics."', () => {
          actions.receiveRemoveItemFailure(
            {
              commit: () => {},
            },
            {
              item: { type: ChildType.Epic },
            },
          );

          expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
            'An error occurred while removing epics.',
          );
        });
      });

      describe('removeItem', () => {
        let mock;
        const data = {
          parentItem: mockParentItem,
          item: Object.assign({}, mockParentItem, {
            iid: 2,
            relationPath: '/foo/bar',
          }),
        };

        beforeEach(() => {
          mock = new MockAdapter(axios);
        });

        afterEach(() => {
          mock.restore();
        });

        it('should dispatch `requestRemoveItem` and `receiveRemoveItemSuccess` actions on request success', done => {
          mock.onDelete(data.item.relationPath).replyOnce(200, {});

          testAction(
            actions.removeItem,
            { ...data },
            state,
            [],
            [
              {
                type: 'requestRemoveItem',
                payload: { item: data.item },
              },
              {
                type: 'receiveRemoveItemSuccess',
                payload: { parentItem: data.parentItem, item: data.item },
              },
              {
                type: 'setChildrenCount',
                payload: { children: [data.item], isRemoved: true },
              },
            ],
            done,
          );
        });

        it('should dispatch `requestRemoveItem` and `receiveRemoveItemFailure` actions on request failure', done => {
          mock.onDelete(data.item.relationPath).replyOnce(500, {});

          testAction(
            actions.removeItem,
            { ...data },
            state,
            [],
            [
              {
                type: 'requestRemoveItem',
                payload: { item: data.item },
              },
              {
                type: 'receiveRemoveItemFailure',
                payload: { item: data.item, status: undefined },
              },
            ],
            done,
          );
        });
      });

      describe('toggleAddItemForm', () => {
        it('should set `state.showAddItemForm` to true', done => {
          testAction(
            actions.toggleAddItemForm,
            {},
            {},
            [{ type: types.TOGGLE_ADD_ITEM_FORM, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('toggleCreateEpicForm', () => {
        it('should set `state.showCreateEpicForm` to true', done => {
          testAction(
            actions.toggleCreateEpicForm,
            {},
            {},
            [{ type: types.TOGGLE_CREATE_EPIC_FORM, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('setPendingReferences', () => {
        it('should set param value to `state.pendingReference`', done => {
          testAction(
            actions.setPendingReferences,
            {},
            {},
            [{ type: types.SET_PENDING_REFERENCES, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('addPendingReferences', () => {
        it('should add param value to `state.pendingReference`', done => {
          testAction(
            actions.addPendingReferences,
            {},
            {},
            [{ type: types.ADD_PENDING_REFERENCES, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('removePendingReference', () => {
        it('should remove param value to `state.pendingReference`', done => {
          testAction(
            actions.removePendingReference,
            {},
            {},
            [{ type: types.REMOVE_PENDING_REFERENCE, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('setItemInputValue', () => {
        it('should set param value to `state.itemInputValue`', done => {
          testAction(
            actions.setItemInputValue,
            {},
            {},
            [{ type: types.SET_ITEM_INPUT_VALUE, payload: {} }],
            [],
            done,
          );
        });
      });

      describe('requestAddItem', () => {
        it('should set `state.itemAddInProgress` to true', done => {
          testAction(actions.requestAddItem, {}, {}, [{ type: types.REQUEST_ADD_ITEM }], [], done);
        });
      });

      describe('receiveAddItemSuccess', () => {
        it('should set `state.itemAddInProgress` to false and dispatches actions `setPendingReferences`, `setItemInputValue` and `toggleAddItemForm`', done => {
          state.epicsBeginAtIndex = 0;
          const mockEpicsWithoutPerm = mockEpics.map(item =>
            Object.assign({}, item, {
              pathIdSeparator: PathIdSeparator.Epic,
              userPermissions: { adminEpic: undefined },
            }),
          );

          testAction(
            actions.receiveAddItemSuccess,
            { actionType: ActionType.Epic, rawItems: mockEpicsWithoutPerm },
            state,
            [
              {
                type: types.RECEIVE_ADD_ITEM_SUCCESS,
                payload: {
                  insertAt: 0,
                  items: mockEpicsWithoutPerm,
                },
              },
            ],
            [
              {
                type: 'setChildrenCount',
                payload: { children: mockEpicsWithoutPerm },
              },
              {
                type: 'setItemChildrenFlags',
                payload: { children: mockEpicsWithoutPerm, isSubItem: false },
              },
              {
                type: 'setPendingReferences',
                payload: [],
              },
              {
                type: 'setItemInputValue',
                payload: '',
              },
              {
                type: 'toggleAddItemForm',
                payload: { actionType: ActionType.Epic, toggleState: false },
              },
            ],
            done,
          );
        });
      });

      describe('receiveAddItemFailure', () => {
        beforeEach(() => {
          setFixtures('<div class="flash-container"></div>');
        });

        it('should set `state.itemAddInProgress` to false', done => {
          testAction(
            actions.receiveAddItemFailure,
            {},
            {},
            [
              {
                type: types.RECEIVE_ADD_ITEM_FAILURE,
              },
            ],
            [],
            done,
          );
        });

        it('should show flash error with message "Something went wrong while adding item."', () => {
          const message = 'Something went wrong while adding item.';
          actions.receiveAddItemFailure(
            {
              commit: () => {},
              state: { actionType: ActionType.Epic },
            },
            {
              message,
            },
          );

          expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
            message,
          );
        });
      });

      describe('addItem', () => {
        let mock;

        beforeEach(() => {
          mock = new MockAdapter(axios);
        });

        afterEach(() => {
          mock.restore();
        });

        it('should dispatch `requestAddItem` and `receiveAddItemSuccess` actions on request success', done => {
          state.actionType = ActionType.Epic;
          state.epicsEndpoint = '/foo/bar';
          state.pendingReferences = ['foo'];

          mock.onPost(state.epicsEndpoint).replyOnce(200, { issuables: [mockEpic1] });

          testAction(
            actions.addItem,
            {},
            state,
            [],
            [
              {
                type: 'requestAddItem',
              },
              {
                type: 'receiveAddItemSuccess',
                payload: { actionType: ActionType.Epic, rawItems: [mockEpic1] },
              },
            ],
            done,
          );
        });

        it('should dispatch `requestAddItem` and `receiveAddItemFailure` actions on request failure', done => {
          state.actionType = ActionType.Epic;
          state.epicsEndpoint = '/foo/bar';
          state.pendingReferences = ['foo'];

          mock.onPost(state.epicsEndpoint).replyOnce(500, {});

          testAction(
            actions.addItem,
            {},
            state,
            [],
            [
              {
                type: 'requestAddItem',
              },
              {
                type: 'receiveAddItemFailure',
              },
            ],
            done,
          );
        });
      });

      describe('requestCreateItem', () => {
        it('should set `state.itemCreateInProgress` to true', done => {
          testAction(
            actions.requestCreateItem,
            {},
            {},
            [{ type: types.REQUEST_CREATE_ITEM }],
            [],
            done,
          );
        });
      });

      describe('receiveCreateItemSuccess', () => {
        it('should set `state.itemCreateInProgress` to false', done => {
          const createdEpic = Object.assign({}, mockEpics[0], {
            id: `gid://gitlab/Epic/${mockEpics[0].id}`,
            reference: `${mockEpics[0].group.fullPath}${mockEpics[0].reference}`,
            pathIdSeparator: '&',
          });
          state.epicsBeginAtIndex = 0;
          state.parentItem = {
            fullPath: createdEpic.group.fullPath,
          };

          testAction(
            actions.receiveCreateItemSuccess,
            { rawItem: mockEpic1, actionType: ActionType.Epic },
            state,
            [
              {
                type: types.RECEIVE_CREATE_ITEM_SUCCESS,
                payload: { insertAt: 0, item: createdEpic },
              },
            ],
            [
              {
                type: 'setChildrenCount',
                payload: { children: [createdEpic] },
              },
              {
                type: 'setItemChildrenFlags',
                payload: { children: [createdEpic], isSubItem: false },
              },
              {
                type: 'toggleCreateEpicForm',
                payload: { actionType: ActionType.Epic, toggleState: false },
              },
            ],
            done,
          );
        });
      });

      describe('receiveCreateItemFailure', () => {
        beforeEach(() => {
          setFixtures('<div class="flash-container"></div>');
        });

        it('should set `state.itemCreateInProgress` to false', done => {
          testAction(
            actions.receiveCreateItemFailure,
            {},
            {},
            [{ type: types.RECEIVE_CREATE_ITEM_FAILURE }],
            [],
            done,
          );
        });

        it('should show flash error with message "Something went wrong while creating child epics."', () => {
          const message = 'Something went wrong while creating child epics.';
          actions.receiveCreateItemFailure(
            {
              commit: () => {},
              state: { actionType: ActionType.Epic },
            },
            {
              message,
            },
          );

          expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
            message,
          );
        });
      });

      describe('createItem', () => {
        let mock;

        beforeEach(() => {
          mock = new MockAdapter(axios);
          state.parentItem = mockParentItem;
          state.actionType = ActionType.Epic;
        });

        afterEach(() => {
          mock.restore();
        });

        it('should dispatch `requestCreateItem` and `receiveCreateItemSuccess` actions on request success', done => {
          mock.onPost(/(.*)/).replyOnce(200, mockEpic1);

          testAction(
            actions.createItem,
            { itemTitle: 'Sample child epic' },
            state,
            [],
            [
              {
                type: 'requestCreateItem',
              },
              {
                type: 'receiveCreateItemSuccess',
                payload: {
                  actionType: ActionType.Epic,
                  rawItem: Object.assign({}, mockEpic1, {
                    path: '',
                    state: ChildState.Open,
                    created_at: '',
                  }),
                },
              },
            ],
            done,
          );
        });

        it('should dispatch `requestCreateItem` and `receiveCreateItemFailure` actions on request failure', done => {
          mock.onPost(/(.*)/).replyOnce(500, {});

          testAction(
            actions.createItem,
            { itemTitle: 'Sample child epic' },
            state,
            [],
            [
              {
                type: 'requestCreateItem',
              },
              {
                type: 'receiveCreateItemFailure',
              },
            ],
            done,
          );
        });
      });

      describe('receiveReorderItemFailure', () => {
        beforeEach(() => {
          setFixtures('<div class="flash-container"></div>');
        });

        it('should revert reordered item back to its original position via REORDER_ITEM mutation', done => {
          testAction(
            actions.receiveReorderItemFailure,
            {},
            {},
            [{ type: types.REORDER_ITEM, payload: {} }],
            [],
            done,
          );
        });

        it('should show flash error with message "Something went wrong while ordering item."', () => {
          const message = 'Something went wrong while ordering item.';
          actions.receiveReorderItemFailure(
            {
              commit: () => {},
            },
            {
              message,
            },
          );

          expect(document.querySelector('.flash-container .flash-text').innerText.trim()).toBe(
            message,
          );
        });
      });

      describe('reorderItem', () => {
        it('should perform REORDER_ITEM mutation before request and do nothing on request success', done => {
          spyOn(epicUtils.gqClient, 'mutate').and.returnValue(
            Promise.resolve({
              data: mockReorderMutationResponse,
            }),
          );

          testAction(
            actions.reorderItem,
            {
              treeReorderMutation: mockEpicTreeReorderInput.moved,
              parentItem: mockParentItem,
              targetItem: mockItems[1],
              oldIndex: 1,
              newIndex: 0,
            },
            {},
            [
              {
                type: types.REORDER_ITEM,
                payload: {
                  parentItem: mockParentItem,
                  targetItem: mockItems[1],
                  oldIndex: 1,
                  newIndex: 0,
                },
              },
            ],
            [],
            done,
          );
        });

        it('should perform REORDER_ITEM mutation before request and dispatch `receiveReorderItemFailure` when request response has errors on request success', done => {
          spyOn(epicUtils.gqClient, 'mutate').and.returnValue(
            Promise.resolve({
              data: {
                epicTreeReorder: {
                  ...mockReorderMutationResponse.epicTreeReorder,
                  errors: [{ foo: 'bar' }],
                },
              },
            }),
          );

          testAction(
            actions.reorderItem,
            {
              treeReorderMutation: mockEpicTreeReorderInput.moved,
              parentItem: mockParentItem,
              targetItem: mockItems[1],
              oldIndex: 1,
              newIndex: 0,
            },
            {},
            [
              {
                type: types.REORDER_ITEM,
                payload: {
                  parentItem: mockParentItem,
                  targetItem: mockItems[1],
                  oldIndex: 1,
                  newIndex: 0,
                },
              },
            ],
            [
              {
                type: 'receiveReorderItemFailure',
                payload: {
                  parentItem: mockParentItem,
                  targetItem: mockItems[1],
                  oldIndex: 0,
                  newIndex: 1,
                },
              },
            ],
            done,
          );
        });

        it('should perform REORDER_ITEM mutation before request and dispatch `receiveReorderItemFailure` on request failure', done => {
          spyOn(epicUtils.gqClient, 'mutate').and.returnValue(Promise.reject());

          testAction(
            actions.reorderItem,
            {
              treeReorderMutation: mockEpicTreeReorderInput.moved,
              parentItem: mockParentItem,
              targetItem: mockItems[1],
              oldIndex: 1,
              newIndex: 0,
            },
            {},
            [
              {
                type: types.REORDER_ITEM,
                payload: {
                  parentItem: mockParentItem,
                  targetItem: mockItems[1],
                  oldIndex: 1,
                  newIndex: 0,
                },
              },
            ],
            [
              {
                type: 'receiveReorderItemFailure',
                payload: {
                  parentItem: mockParentItem,
                  targetItem: mockItems[1],
                  oldIndex: 0,
                  newIndex: 1,
                },
              },
            ],
            done,
          );
        });
      });
    });
  });
});
