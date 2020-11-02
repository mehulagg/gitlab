import Vue from 'vue';
import { shallowMount } from '@vue/test-utils';
import IssuesLaneList from 'ee/boards/components/issues_lane_list.vue';
import { listObj } from 'jest/boards/mock_data';
import BoardCard from '~/boards/components/board_card_layout.vue';
import BoardCardLoading from '~/boards/components/board_card_loading.vue';
import { mockIssues } from '../mock_data';
import List from '~/boards/models/list';
import { createStore } from '~/boards/stores';
import { ListType } from '~/boards/constants';

describe('IssuesLaneList', () => {
  let wrapper;
  let store;

  const createComponent = ({
    listType = ListType.backlog,
    collapsed = false,
    withLocalStorage = true,
    isLoading = false,
    issues = mockIssues,
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
    const list = Vue.observable(new List({ ...listMock, doNotFetchIssues: true }));

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
        issues,
        disabled: false,
        isLoading,
      },
    });
  };

  afterEach(() => {
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

    it('renders loading skeleton when issues are loading', () => {
      createComponent({ issues: [], isLoading: true });
      expect(wrapper.findAll(BoardCardLoading)).toHaveLength(1);
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

    it('does not render loading skeleton when issues are loading', () => {
      createComponent({ issues: [], isLoading: true, collapsed: true });
      expect(wrapper.findAll(BoardCardLoading)).toHaveLength(0);
    });
  });
});
