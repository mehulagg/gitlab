import { shallowMount } from '@vue/test-utils';

import SidebarItemEpicsSelect from 'ee/sidebar/components/sidebar_item_epics_select.vue';
import EpicsSelect from 'ee/vue_shared/components/sidebar/epics_select/base.vue';

import {
  mockSidebarStore,
  mockEpic1,
  mockIssue,
} from 'ee_jest/vue_shared/components/sidebar/mock_data';

describe('SidebarItemEpicsSelect', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(SidebarItemEpicsSelect, {
      stubs: {
        'epics-select': true,
      },
      propsData: {
        canEdit: true,
        sidebarStore: mockSidebarStore,
        epicIssueId: mockSidebarStore.epic_issue_id,
        groupId: mockEpic1.group_id,
        issueId: mockIssue.id,
      },
    });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('methods', () => {
    describe('getInitialEpicLoading', () => {
      it('should return `false` when `initialEpic` prop is provided', async () => {
        wrapper.setProps({
          initialEpic: mockEpic1,
        });

        await wrapper.vm.$nextTick();
        expect(wrapper.vm.getInitialEpicLoading()).toBe(false);
      });

      it('should return value of `sidebarStore.isFetching.epic` when `initialEpic` prop is null and `isFetching` is available', async () => {
        wrapper.setProps({
          sidebarStore: { isFetching: { epic: true } },
        });

        await wrapper.vm.$nextTick();
        expect(wrapper.vm.getInitialEpicLoading()).toBe(true);
      });

      it('should return `false` when both `initialEpic` and `sidebarStore.isFetching` are unavailable', async () => {
        wrapper.setProps({
          initialEpic: null,
          sidebarStore: { isFetching: null },
        });

        await wrapper.vm.$nextTick();
        expect(wrapper.vm.getInitialEpicLoading()).toBe(false);
      });
    });

    describe('getEpic', () => {
      it('should return value of `initialEpic` as it is when it is available', async () => {
        wrapper.setProps({
          initialEpic: mockEpic1,
        });

        await wrapper.vm.$nextTick();
        expect(wrapper.vm.getEpic()).toBe(mockEpic1);
      });

      it('should return value of `sidebarStore.epic` as it is when it is available', () => {
        expect(wrapper.vm.getEpic()).toBe(mockEpic1);
      });

      it('should return No Epic object as it is when both `initialEpic` & `sidebarStore.epic` are unavailable', async () => {
        wrapper.setProps({
          initialEpic: null,
          sidebarStore: { epic: null },
        });

        await wrapper.vm.$nextTick();
        expect(wrapper.vm.getEpic()).toEqual(
          expect.objectContaining({
            id: 0,
            title: 'No Epic',
          }),
        );
      });
    });
  });

  describe('template', () => {
    it('should render epics-select component', () => {
      expect(wrapper.find(EpicsSelect).element).toBe(wrapper.element);
      expect(wrapper.text()).toBe('None');
    });
  });
});
