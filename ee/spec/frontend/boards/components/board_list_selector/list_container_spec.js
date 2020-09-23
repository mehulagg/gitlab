import { shallowMount } from '@vue/test-utils';
import Vue from 'vue';
import ListContainer from 'ee/boards/components/boards_list_selector/list_container.vue';
import ListFilter from 'ee/boards/components/boards_list_selector/list_filter.vue';
import ListContent from 'ee/boards/components/boards_list_selector/list_content.vue';
import { mockAssigneesList } from 'jest/boards/mock_data';

describe('ListContainer', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(ListContainer, {
      propsData: {
        loading: false,
        items: mockAssigneesList,
        listType: 'assignees',
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('filteredItems', () => {
      it('returns assignees list as it is when `query` is empty', () => {
        wrapper.setData({ query: '' });

        expect(wrapper.vm.filteredItems).toHaveLength(mockAssigneesList.length);
      });

      it('returns filtered assignees list as it is when `query` has name', () => {
        const assignee = mockAssigneesList[0];

        wrapper.setData({ query: assignee.name });

        expect(wrapper.vm.filteredItems).toHaveLength(1);
        expect(wrapper.vm.filteredItems[0].name).toBe(assignee.name);
      });

      it('returns filtered assignees list as it is when `query` has username', () => {
        const assignee = mockAssigneesList[0];

        wrapper.setData({ query: assignee.username });

        expect(wrapper.vm.filteredItems).toHaveLength(1);
        expect(wrapper.vm.filteredItems[0].username).toBe(assignee.username);
      });
    });
  });

  describe('methods', () => {
    describe('handleSearch', () => {
      it('sets value of param `query` to component prop `query`', () => {
        const query = 'foobar';
        wrapper.vm.handleSearch(query);

        expect(wrapper.vm.query).toBe(query);
      });
    });

    describe('handleItemClick', () => {
      it('emits `onItemSelect` event on component and sends `assignee` as event param', () => {
        const assignee = mockAssigneesList[0];

        wrapper.vm.handleItemClick(assignee);

        expect(wrapper.emitted().onItemSelect[0]).toEqual([assignee]);
      });
    });
  });

  describe('template', () => {
    it('renders component container element with class `dropdown-assignees-list`', () => {
      expect(wrapper.classes('dropdown-assignees-list')).toBe(true);
    });

    it('renders loading animation when prop `loading` is true', () => {
      wrapper.setProps({ loading: true });

      return Vue.nextTick().then(() => {
        expect(wrapper.find('.dropdown-loading').exists()).toBe(true);
      });
    });

    it('renders dropdown body elements', () => {
      expect(wrapper.find(ListFilter).exists()).toBe(true);
      expect(wrapper.find(ListContent).exists()).toBe(true);
    });
  });
});
