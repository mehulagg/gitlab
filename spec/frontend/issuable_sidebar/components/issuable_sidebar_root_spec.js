import { shallowMount } from '@vue/test-utils';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';

import IssuableSidebarRoot from '~/issuable_sidebar/components/issuable_sidebar_root.vue';

const createComponent = (expanded = true) =>
  shallowMount(IssuableSidebarRoot, {
    propsData: {
      expanded,
    },
    slots: {
      'right-sidebar-items': `
        <button class="js-todo">Todo</button>
      `,
    },
  });

describe('IssuableSidebarRoot', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('handleWindowResize', () => {
      it.each`
        expanded | breakpoint | isExpandedValue
        ${true}  | ${'xs'}    | ${false}
        ${true}  | ${'sm'}    | ${false}
        ${true}  | ${'md'}    | ${false}
        ${true}  | ${'lg'}    | ${true}
        ${true}  | ${'xl'}    | ${true}
        ${false} | ${'xl'}    | ${false}
      `(
        'sets `isExpanded` prop to $isExpandedValue when `expanded` prop value is $expanded and current window width is "$breakpoint"',
        async ({ expanded, breakpoint, isExpandedValue }) => {
          wrapper.setProps({
            expanded,
          });

          await wrapper.vm.$nextTick();

          jest.spyOn(bp, 'getBreakpointSize').mockReturnValue(breakpoint);

          wrapper.vm.handleWindowResize();

          expect(wrapper.vm.isExpanded).toBe(isExpandedValue);
        },
      );

      it('emits `sidebar-toggle` event on component', async () => {
        wrapper.setProps({
          expanded: true,
        });

        await wrapper.vm.$nextTick();

        jest.spyOn(bp, 'getBreakpointSize').mockReturnValue('lg');

        wrapper.vm.handleWindowResize();

        expect(wrapper.emitted('sidebar-toggle')).toBeTruthy();
        expect(wrapper.emitted('sidebar-toggle')[0]).toEqual([
          {
            expanded: true,
            manual: false,
          },
        ]);
      });
    });

    describe('handleToggleSidebarClick', () => {
      it('emits `sidebar-toggle` event on component', async () => {
        wrapper.setData({
          isExpanded: false,
        });

        wrapper.vm.handleToggleSidebarClick();

        expect(wrapper.emitted('sidebar-toggle')).toBeTruthy();
        expect(wrapper.emitted('sidebar-toggle')[0]).toEqual([
          {
            expanded: true,
            manual: true,
          },
        ]);
      });
    });
  });

  describe('template', () => {
    describe('sidebar expanded', () => {
      beforeEach(async () => {
        wrapper.setData({
          isExpanded: true,
        });

        await wrapper.vm.$nextTick();
      });

      it('renders component container element with class `right-sidebar-expanded` when `isExpanded` prop is true', () => {
        expect(wrapper.classes()).toContain('right-sidebar-expanded');
      });

      it('renders sidebar toggle button with text and icon', () => {
        const buttonEl = wrapper.find('button');

        expect(buttonEl.exists()).toBe(true);
        expect(buttonEl.attributes('title')).toBe('Toggle sidebar');
        expect(buttonEl.find('span').text()).toBe('Collapse sidebar');
        expect(buttonEl.find('[data-testid="icon-collapse"]').isVisible()).toBe(true);
      });
    });

    describe('sidebar collapsed', () => {
      beforeEach(async () => {
        wrapper.setData({
          isExpanded: false,
        });

        await wrapper.vm.$nextTick();
      });

      it('renders component container element with class `right-sidebar-collapsed` when `isExpanded` prop is false', () => {
        expect(wrapper.classes()).toContain('right-sidebar-collapsed');
      });

      it('renders sidebar toggle button with text and icon', () => {
        const buttonEl = wrapper.find('button');

        expect(buttonEl.exists()).toBe(true);
        expect(buttonEl.attributes('title')).toBe('Toggle sidebar');
        expect(buttonEl.find('[data-testid="icon-expand"]').isVisible()).toBe(true);
      });
    });

    it('renders sidebar items', () => {
      const sidebarItemsEl = wrapper.find('[data-testid="sidebar-items"]');

      expect(sidebarItemsEl.exists()).toBe(true);
      expect(sidebarItemsEl.find('button.js-todo').exists()).toBe(true);
    });
  });
});
