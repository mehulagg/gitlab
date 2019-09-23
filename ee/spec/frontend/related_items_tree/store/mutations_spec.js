import mutations from 'ee/related_items_tree/store/mutations';
import createDefaultState from 'ee/related_items_tree/store/state';

import * as types from 'ee/related_items_tree/store/mutation_types';

describe('RelatedItemsTree', () => {
  describe('store', () => {
    describe('mutations', () => {
      let state;

      beforeEach(() => {
        state = createDefaultState();
      });

      describe(types.SET_INITIAL_CONFIG, () => {
        it('should set provided `data` param props to state', () => {
          const data = {
            epicsEndpoint: '/foo',
            issuesEndpoint: '/bar',
            autoCompleteEpics: true,
            autoCompleteIssues: false,
          };

          mutations[types.SET_INITIAL_CONFIG](state, data);

          expect(state).toHaveProperty('epicsEndpoint', '/foo');
          expect(state).toHaveProperty('issuesEndpoint', '/bar');
          expect(state).toHaveProperty('autoCompleteEpics', true);
          expect(state).toHaveProperty('autoCompleteIssues', false);
        });
      });

      describe(types.SET_INITIAL_PARENT_ITEM, () => {
        it('should set provided `data` param props to state.parentItem', () => {
          const data = {
            foo: 'bar',
            bar: 'baz',
            reference: '&1',
          };

          mutations[types.SET_INITIAL_PARENT_ITEM](state, data);

          expect(state.parentItem).toHaveProperty('foo', 'bar');
          expect(state.parentItem).toHaveProperty('bar', 'baz');
          expect(state.childrenFlags[data.reference]).toBeDefined();
        });
      });

      describe(types.SET_CHILDREN_COUNT, () => {
        it('should set provided `epicsCount` and `issuesCount` to state', () => {
          const data = {
            epicsCount: 4,
            issuesCount: 5,
          };

          mutations[types.SET_CHILDREN_COUNT](state, data);

          expect(state.epicsCount).toBe(data.epicsCount);
          expect(state.issuesCount).toBe(data.issuesCount);
        });
      });

      describe(types.SET_ITEM_CHILDREN, () => {
        const data = {
          parentItem: { reference: '&1' },
          children: [
            {
              reference: 'frontend&1',
            },
            {
              reference: 'frontend&2',
            },
          ],
        };

        it('should set provided children to parent in the state', () => {
          mutations[types.SET_ITEM_CHILDREN](state, data);

          expect(state.children[data.parentItem.reference]).toEqual(
            expect.arrayContaining(data.children),
          );
        });

        it('should append provided children to parent in the state when `append` param is `true`', () => {
          mutations[types.SET_ITEM_CHILDREN](state, data);
          data.append = true;
          mutations[types.SET_ITEM_CHILDREN](state, data);

          expect(state.children[data.parentItem.reference].length).toEqual(4);
        });
      });

      describe(types.SET_ITEM_CHILDREN_FLAGS, () => {
        it('should set flags in `state.childrenFlags` for each item in `data.children`', () => {
          const data = {
            children: [
              {
                reference: '&1',
                hasChildren: true,
                hasIssues: false,
              },
              {
                reference: '&2',
                hasChildren: false,
                hasIssues: true,
              },
            ],
          };

          mutations[types.SET_ITEM_CHILDREN_FLAGS](state, data);

          data.children.forEach(item => {
            expect(state.childrenFlags[item.reference]).toEqual(
              expect.objectContaining({
                itemExpanded: false,
                itemChildrenFetchInProgress: false,
                itemRemoveInProgress: false,
                itemHasChildren: true,
              }),
            );
          });
        });
      });

      describe(types.SET_EPIC_PAGE_INFO, () => {
        it('should set `epicEndCursor` and `hasMoreEpics` to `state.childrenFlags`', () => {
          const data = {
            parentItem: { reference: '&1' },
            pageInfo: {
              endCursor: 'abc',
              hasNextPage: true,
            },
          };
          state.childrenFlags[data.parentItem.reference] = {};

          mutations[types.SET_EPIC_PAGE_INFO](state, data);

          expect(state.childrenFlags[data.parentItem.reference].epicEndCursor).toEqual(
            data.pageInfo.endCursor,
          );
          expect(state.childrenFlags[data.parentItem.reference].hasMoreEpics).toEqual(
            data.pageInfo.hasNextPage,
          );
        });
      });

      describe(types.SET_ISSUE_PAGE_INFO, () => {
        it('should set `issueEndCursor` and `hasMoreIssues` to `state.childrenFlags`', () => {
          const data = {
            parentItem: { reference: '&1' },
            pageInfo: {
              endCursor: 'abc',
              hasNextPage: true,
            },
          };
          state.childrenFlags[data.parentItem.reference] = {};

          mutations[types.SET_ISSUE_PAGE_INFO](state, data);

          expect(state.childrenFlags[data.parentItem.reference].issueEndCursor).toEqual(
            data.pageInfo.endCursor,
          );
          expect(state.childrenFlags[data.parentItem.reference].hasMoreIssues).toEqual(
            data.pageInfo.hasNextPage,
          );
        });
      });

      describe(types.REQUEST_ITEMS, () => {
        const data = {
          parentItem: {
            reference: '&1',
          },
        };

        it('should set `itemChildrenFetchInProgress` to true for provided `parentItem` param within state.childrenFlags when `isSubItem` param is true', () => {
          data.isSubItem = true;
          state.childrenFlags[data.parentItem.reference] = {};
          mutations[types.REQUEST_ITEMS](state, data);

          expect(state.childrenFlags[data.parentItem.reference]).toHaveProperty(
            'itemChildrenFetchInProgress',
            true,
          );
        });

        it('should set `state.itemsFetchInProgress` to true when `isSubItem` param is false', () => {
          data.isSubItem = false;
          mutations[types.REQUEST_ITEMS](state, data);

          expect(state.itemsFetchInProgress).toBe(true);
        });
      });

      describe(types.RECEIVE_ITEMS_SUCCESS, () => {
        const data = {
          parentItem: {
            reference: '&1',
          },
        };

        it('should set `itemChildrenFetchInProgress` to false for provided `parentItem` param within state.childrenFlags when `isSubItem` param is true', () => {
          data.isSubItem = true;
          state.childrenFlags[data.parentItem.reference] = {};
          mutations[types.RECEIVE_ITEMS_SUCCESS](state, data);

          expect(state.childrenFlags[data.parentItem.reference]).toHaveProperty(
            'itemChildrenFetchInProgress',
            false,
          );
        });

        it('should set `state.itemsFetchInProgress` to false and `state.itemsFetchResultEmpty` based on provided children param count when `isSubItem` param is false', () => {
          data.isSubItem = false;
          data.children = [];
          mutations[types.RECEIVE_ITEMS_SUCCESS](state, data);

          expect(state.itemsFetchInProgress).toBe(false);
          expect(state.itemsFetchResultEmpty).toBe(true);
        });
      });

      describe(types.RECEIVE_ITEMS_FAILURE, () => {
        const data = {
          parentItem: {
            reference: '&1',
          },
        };

        it('should set `itemChildrenFetchInProgress` to false for provided `parentItem` param within state.childrenFlags when `isSubItem` param is true', () => {
          data.isSubItem = true;
          state.childrenFlags[data.parentItem.reference] = {};
          mutations[types.RECEIVE_ITEMS_FAILURE](state, data);

          expect(state.childrenFlags[data.parentItem.reference]).toHaveProperty(
            'itemChildrenFetchInProgress',
            false,
          );
        });

        it('should set `state.itemsFetchInProgress` to false and `state.itemsFetchResultEmpty` based on provided children param count when `isSubItem` param is false', () => {
          data.isSubItem = false;
          mutations[types.RECEIVE_ITEMS_FAILURE](state, data);

          expect(state.itemsFetchInProgress).toBe(false);
        });
      });

      describe(types.EXPAND_ITEM, () => {
        const data = {
          parentItem: {
            reference: '&1',
          },
        };

        it('should set `itemExpanded` to true for provided `parentItem` param within state.childrenFlags', () => {
          state.childrenFlags[data.parentItem.reference] = {};
          mutations[types.EXPAND_ITEM](state, data);

          expect(state.childrenFlags[data.parentItem.reference]).toHaveProperty(
            'itemExpanded',
            true,
          );
        });
      });

      describe(types.COLLAPSE_ITEM, () => {
        const data = {
          parentItem: {
            reference: '&1',
          },
        };

        it('should set `itemExpanded` to false for provided `parentItem` param within state.childrenFlags', () => {
          state.childrenFlags[data.parentItem.reference] = {};
          mutations[types.COLLAPSE_ITEM](state, data);

          expect(state.childrenFlags[data.parentItem.reference]).toHaveProperty(
            'itemExpanded',
            false,
          );
        });
      });

      describe(types.SET_REMOVE_ITEM_MODAL_PROPS, () => {
        it('should set `parentItem` & `item` to state.removeItemModalProps', () => {
          const data = {
            parentItem: 'foo',
            item: 'bar',
          };

          mutations[types.SET_REMOVE_ITEM_MODAL_PROPS](state, data);

          expect(state.removeItemModalProps).toEqual(
            expect.objectContaining({
              parentItem: data.parentItem,
              item: data.item,
            }),
          );
        });
      });

      describe(types.REQUEST_REMOVE_ITEM, () => {
        it('should set `itemRemoveInProgress` to true for provided `item` param within state.childrenFlags', () => {
          const data = {
            item: {
              reference: '&1',
            },
          };
          state.childrenFlags[data.item.reference] = {};

          mutations[types.REQUEST_REMOVE_ITEM](state, data);

          expect(state.childrenFlags[data.item.reference]).toHaveProperty(
            'itemRemoveInProgress',
            true,
          );
        });
      });

      describe(types.RECEIVE_REMOVE_ITEM_SUCCESS, () => {
        const data = {
          parentItem: {
            reference: 'gitlab-org&1',
          },
          item: {
            reference: '&2',
          },
        };

        it('should set `itemRemoveInProgress` to false for provided `item` param within state.childrenFlags and removes children for provided `parentItem`', () => {
          state.children[data.parentItem.reference] = [data.item];
          state.childrenFlags[data.item.reference] = {};
          state.childrenFlags[data.parentItem.reference] = {};

          mutations[types.RECEIVE_REMOVE_ITEM_SUCCESS](state, data);

          expect(state.childrenFlags[data.item.reference]).toHaveProperty(
            'itemRemoveInProgress',
            false,
          );

          expect(state.children[data.parentItem.reference]).toEqual(expect.arrayContaining([]));
          expect(state.childrenFlags[data.parentItem.reference].itemHasChildren).toBe(false);
        });
      });

      describe(types.RECEIVE_REMOVE_ITEM_FAILURE, () => {
        it('should set `itemRemoveInProgress` to false for provided `item` param within state.childrenFlags', () => {
          const data = {
            item: {
              reference: '&1',
            },
          };
          state.childrenFlags[data.item.reference] = {};

          mutations[types.RECEIVE_REMOVE_ITEM_FAILURE](state, data);

          expect(state.childrenFlags[data.item.reference]).toHaveProperty(
            'itemRemoveInProgress',
            false,
          );
        });
      });

      describe(types.TOGGLE_ADD_ITEM_FORM, () => {
        it('should set value of `actionType`, `showAddItemForm` as it is and `showCreateEpicForm` as false on state', () => {
          const data = {
            actionType: 'Epic',
            toggleState: true,
          };

          mutations[types.TOGGLE_ADD_ITEM_FORM](state, data);

          expect(state.actionType).toBe(data.actionType);
          expect(state.showAddItemForm).toBe(data.toggleState);
          expect(state.showCreateEpicForm).toBe(false);
        });
      });

      describe(types.TOGGLE_CREATE_EPIC_FORM, () => {
        it('should set value of `actionType`, `showCreateEpicForm` as it is and `showAddItemForm` as false on state', () => {
          const data = {
            actionType: 'Epic',
            toggleState: true,
          };

          mutations[types.TOGGLE_CREATE_EPIC_FORM](state, data);

          expect(state.actionType).toBe(data.actionType);
          expect(state.showCreateEpicForm).toBe(data.toggleState);
          expect(state.showAddItemForm).toBe(false);
        });
      });

      describe(types.SET_PENDING_REFERENCES, () => {
        it('should set `pendingReferences` to state based on provided `references` param', () => {
          const reference = ['foo'];

          mutations[types.SET_PENDING_REFERENCES](state, reference);

          expect(state.pendingReferences).toEqual(expect.arrayContaining(reference));
        });
      });

      describe(types.ADD_PENDING_REFERENCES, () => {
        it('should add value of provided `references` param to `pendingReferences` within state', () => {
          const reference = ['bar'];
          state.pendingReferences = ['foo'];

          mutations[types.ADD_PENDING_REFERENCES](state, reference);

          expect(state.pendingReferences).toEqual(
            expect.arrayContaining(['foo'].concat(reference)),
          );
        });
      });

      describe(types.REMOVE_PENDING_REFERENCE, () => {
        it('should remove value from `pendingReferences` based on provided `indexToRemove` param', () => {
          state.pendingReferences = ['foo', 'bar'];

          mutations[types.REMOVE_PENDING_REFERENCE](state, 1);

          expect(state.pendingReferences).toEqual(expect.arrayContaining(['foo']));
        });
      });

      describe(types.SET_ITEM_INPUT_VALUE, () => {
        it('should set value of provided `itemInputValue` param to `itemInputValue` within state', () => {
          mutations[types.SET_ITEM_INPUT_VALUE](state, 'foo');

          expect(state.itemInputValue).toBe('foo');
        });
      });

      describe(types.REQUEST_ADD_ITEM, () => {
        it('should set `itemAddInProgress` to true within state', () => {
          mutations[types.REQUEST_ADD_ITEM](state);

          expect(state.itemAddInProgress).toBe(true);
        });
      });

      describe(types.RECEIVE_ADD_ITEM_SUCCESS, () => {
        it('should add provided `items` param to `state.children` and `itemAddInProgress` to false', () => {
          state.parentItem = { reference: '&1' };
          state.children[state.parentItem.reference] = ['foo', 'baz'];

          mutations[types.RECEIVE_ADD_ITEM_SUCCESS](state, {
            insertAt: 1,
            items: ['bar'],
          });

          expect(state.children[state.parentItem.reference]).toEqual(
            expect.arrayContaining(['foo', 'bar', 'baz']),
          );
          expect(state.itemAddInProgress).toBe(false);
          expect(state.itemsFetchResultEmpty).toBe(false);
        });
      });

      describe(types.RECEIVE_ADD_ITEM_FAILURE, () => {
        it('should set `itemAddInProgress` to false within state', () => {
          mutations[types.RECEIVE_ADD_ITEM_FAILURE](state);

          expect(state.itemAddInProgress).toBe(false);
        });
      });

      describe(types.REQUEST_CREATE_ITEM, () => {
        it('should set `itemCreateInProgress` to true within state', () => {
          mutations[types.REQUEST_CREATE_ITEM](state);

          expect(state.itemCreateInProgress).toBe(true);
        });
      });

      describe(types.RECEIVE_CREATE_ITEM_SUCCESS, () => {
        it('should add provided `item` param to `state.children` and `itemCreateInProgress` to false', () => {
          state.parentItem = { reference: '&1' };
          state.children[state.parentItem.reference] = ['foo', 'baz'];

          mutations[types.RECEIVE_CREATE_ITEM_SUCCESS](state, {
            insertAt: 1,
            item: 'bar',
          });

          expect(state.children[state.parentItem.reference]).toEqual(
            expect.arrayContaining(['foo', 'bar', 'baz']),
          );
          expect(state.itemCreateInProgress).toBe(false);
          expect(state.itemsFetchResultEmpty).toBe(false);
        });
      });

      describe(types.RECEIVE_CREATE_ITEM_FAILURE, () => {
        it('should set `itemCreateInProgress` to false within state', () => {
          mutations[types.RECEIVE_CREATE_ITEM_FAILURE](state);

          expect(state.itemCreateInProgress).toBe(false);
        });
      });

      describe(types.REORDER_ITEM, () => {
        it('should reorder an item within children of provided parent based on provided indices', () => {
          state.parentItem = { reference: '&1' };
          state.children[state.parentItem.reference] = ['foo', 'bar'];

          mutations[types.REORDER_ITEM](state, {
            parentItem: {
              reference: '&1',
            },
            targetItem: 'bar',
            oldIndex: 1,
            newIndex: 0,
          });

          expect(state.children[state.parentItem.reference]).toEqual(
            expect.arrayContaining(['bar', 'foo']),
          );
        });
      });
    });
  });
});
