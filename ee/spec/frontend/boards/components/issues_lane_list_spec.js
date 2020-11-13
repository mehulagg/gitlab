import Vue from 'vue';
import AxiosMockAdapter from 'axios-mock-adapter';
import { shallowMount } from '@vue/test-utils';
import IssuesLaneList from 'ee/boards/components/issues_lane_list.vue';
import { listObj } from 'jest/boards/mock_data';
import { TEST_HOST } from 'helpers/test_constants';
import BoardCard from '~/boards/components/board_card_layout.vue';
import axios from '~/lib/utils/axios_utils';
import { mockIssues } from '../mock_data';
import List from '~/boards/models/list';
import { createStore } from '~/boards/stores';
import { ListType } from '~/boards/constants';

describe('IssuesLaneList', () => {
  let wrapper;
  let axiosMock;
  let store;

  beforeEach(() => {
    axiosMock = new AxiosMockAdapter(axios);
    axiosMock.onGet(`${TEST_HOST}/lists/1/issues`).reply(200, { issues: [] });
  });

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    withLocalStorage = true,
  } = {}) => {
    const boardId = '1';

    const listMock = {
      ...listObj,
      list_type: listType,
      collapsed,
    };

    if (listType === ListType.assignee) {
      delete listMock.label;
      listMock.user = {};
    }

    // Making List reactive
    const list = Vue.observable(new List(listMock));

    if (withLocalStorage) {
      localStorage.setItem(
        `boards.${boardId}.${list.type}.${list.id}.expanded`,
        (!collapsed).toString(),
      );
    }

    wrapper = shallowMount(IssuesLaneList, {
      store,
      propsData: {
        list,
        issues: mockIssues,
        disabled: false,
        canAdminList: true,
      },
    });
  };

  afterEach(() => {
    axiosMock.restore();
    wrapper.destroy();
    localStorage.clear();
  });

  describe('if list is expanded', () => {
    beforeEach(() => {
      store = createStore();

      createComponent();
    });

    it('does not have is-collapsed class', () => {
      expect(wrapper.classes('is-collapsed')).toBe(false);
    });

    it('renders one BoardCard component per issue passed in props', () => {
      expect(wrapper.findAll(BoardCard)).toHaveLength(wrapper.props('issues').length);
    });
  });

  describe('if list is collapsed', () => {
    beforeEach(() => {
      store = createStore();

      createComponent({ collapsed: true });
    });

    it('has is-collapsed class', () => {
      expect(wrapper.classes('is-collapsed')).toBe(true);
    });

    it('does not renders BoardCard components', () => {
      expect(wrapper.findAll(BoardCard)).toHaveLength(0);
    });
  });

  describe('drag & drop issue', () => {
    beforeEach(() => {
      const defaultStore = createStore();
      store = {
        ...defaultStore,
        state: {
          ...defaultStore.state,
          canAdminEpic: true,
        },
      };

      createComponent();
    });

    describe('handleDragOnStart', () => {
      it('adds a class `is-dragging` to document body', () => {
        expect(document.body.classList.contains('is-dragging')).toBe(false);

        wrapper.find(`[data-testid="tree-root-wrapper"]`).vm.$emit('start');

        expect(document.body.classList.contains('is-dragging')).toBe(true);
      });
    });

    describe('handleDragOnEnd', () => {
      it('removes class `is-dragging` from document body', () => {
        jest.spyOn(wrapper.vm, 'moveIssue').mockImplementation(() => {});
        document.body.classList.add('is-dragging');

        wrapper.find(`[data-testid="tree-root-wrapper"]`).vm.$emit('end', {
          oldIndex: 1,
          newIndex: 0,
          item: {
            dataset: {
              issueId: mockIssues[0].id,
              issueIid: mockIssues[0].iid,
              issuePath: mockIssues[0].referencePath,
            },
          },
          to: { children: [], dataset: { listId: 'gid://gitlab/List/1' } },
          from: { dataset: { listId: 'gid://gitlab/List/2' } },
        });

        expect(document.body.classList.contains('is-dragging')).toBe(false);
      });
    });
  });
});
