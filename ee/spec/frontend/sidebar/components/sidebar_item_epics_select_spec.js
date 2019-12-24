import { shallowMount } from '@vue/test-utils';

import SidebarItemEpicsSelect from 'ee/sidebar/components/sidebar_item_epics_select.vue';

import {
  mockSidebarStore,
  mockEpic1,
  mockIssue,
} from '../../vue_shared/components/sidebar/mock_data';

describe('SidebarItemEpicsSelect', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = shallowMount(SidebarItemEpicsSelect, {
      sync: false,

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
  });

  describe('methods', () => {
    describe('getInitialEpicLoading', () => {
      it('should return `false` when `initialEpic` prop is provided', done => {
        wrapper.setProps({
          initialEpic: mockEpic1,
        });

        wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.getInitialEpicLoading()).toBe(false);
          done();
        });
      });

      it('should return value of `sidebarStore.isFetching.epic` when `initialEpic` prop is null and `isFetching` is available', done => {
        wrapper.setProps({
          sidebarStore: { isFetching: { epic: true } },
        });

        wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.getInitialEpicLoading()).toBe(true);
          done();
        });
      });

      it('should return `false` when both `initialEpic` and `sidebarStore.isFetching` are unavailable', done => {
        wrapper.setProps({
          initialEpic: null,
          sidebarStore: { isFetching: null },
        });

        wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.getInitialEpicLoading()).toBe(false);
          done();
        });
      });
    });

    describe('getEpic', () => {
      it('should return value of `initialEpic` as it is when it is available', done => {
        wrapper.setProps({
          initialEpic: mockEpic1,
        });

        wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.getEpic()).toBe(mockEpic1);
          done();
        });
      });

      it('should return value of `sidebarStore.epic` as it is when it is available', () => {
        expect(wrapper.vm.getEpic()).toBe(mockEpic1);
      });

      it('should return No Epic object as it is when both `initialEpic` & `sidebarStore.epic` are unavailable', done => {
        wrapper.setProps({
          initialEpic: null,
          sidebarStore: { epic: null },
        });

        wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.getEpic()).toEqual(
            expect.objectContaining({
              id: 0,
              title: 'none',
            }),
          );

          done();
        });
      });
    });
  });

  describe('template', () => {
    it('should render epics-select component', () => {
      expect(wrapper.is('epics-select-stub')).toBe(true);
      expect(wrapper.attributes('blocktitle')).toBe('Epic');
      expect(wrapper.text()).toBe('None');
    });
  });
});
