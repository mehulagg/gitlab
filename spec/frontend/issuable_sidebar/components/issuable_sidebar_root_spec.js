import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import { shallowMount } from '@vue/test-utils';
import Cookies from 'js-cookie';

import IssuableSidebarRoot from '~/issuable_sidebar/components/issuable_sidebar_root.vue';
import { USER_COLLAPSED_GUTTER_COOKIE } from '~/issuable_sidebar/constants';

const createComponent = () =>
  shallowMount(IssuableSidebarRoot, {
    slots: {
      'right-sidebar-items': `
        <button class="js-todo">Todo</button>
      `,
    },
  });

describe('IssuableSidebarRoot', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('updatePageContainerClass', () => {
      beforeEach(() => {
        setFixtures('<div class="layout-page"></div>');
      });

      it.each`
        isExpanded | layoutPageClass
        ${true}    | ${'right-sidebar-expanded'}
        ${false}   | ${'right-sidebar-collapsed'}
      `(
        'set class $layoutPageClass to container element when `isExpanded` prop is $isExpanded',
        async ({ isExpanded, layoutPageClass }) => {
          jest.spyOn(Cookies, 'get').mockReturnValue(!isExpanded);
          jest.spyOn(bp, 'isDesktop').mockReturnValue(isExpanded);

          wrapper = createComponent();

          await wrapper.vm.updatePageContainerClass();

          expect(document.querySelector('.layout-page').classList.contains(layoutPageClass)).toBe(
            true,
          );
        },
      );
    });

    describe('handleWindowResize', () => {
      beforeEach(() => {
        jest.spyOn(Cookies, 'get').mockReturnValue(false);

        wrapper = createComponent();
      });

      it.each`
        breakpoint | isExpandedValue
        ${'xs'}    | ${false}
        ${'sm'}    | ${false}
        ${'md'}    | ${false}
        ${'lg'}    | ${true}
        ${'xl'}    | ${true}
      `(
        'sets `isExpanded` prop to $isExpandedValue only when current screen size is `lg` or `xl`',
        async ({ breakpoint, isExpandedValue }) => {
          jest.spyOn(bp, 'isDesktop').mockReturnValue(breakpoint === 'lg' || breakpoint === 'xl');

          wrapper.vm.handleWindowResize();

          expect(wrapper.vm.isExpanded).toBe(isExpandedValue);
        },
      );

      it('calls `updatePageContainerClass` method', () => {
        jest.spyOn(bp, 'isDesktop').mockReturnValue(false);
        jest.spyOn(wrapper.vm, 'updatePageContainerClass');

        wrapper.vm.handleWindowResize();

        expect(wrapper.vm.updatePageContainerClass).toHaveBeenCalled();
      });
    });

    describe('toggleSidebar', () => {
      beforeEach(() => {
        jest.spyOn(Cookies, 'set').mockImplementation(jest.fn());
        jest.spyOn(Cookies, 'get').mockReturnValue(false);

        wrapper = createComponent();
      });

      it('flips value of `isExpanded`', () => {
        wrapper.vm.toggleSidebar();

        expect(wrapper.vm.isExpanded).toBe(false);
        expect(wrapper.vm.userExpanded).toBe(false);
      });

      it('updates "collapsed_gutter" cookie value', () => {
        wrapper.vm.toggleSidebar();

        expect(Cookies.set).toHaveBeenCalledWith(USER_COLLAPSED_GUTTER_COOKIE, true);
      });

      it('calls `updatePageContainerClass` method', () => {
        jest.spyOn(wrapper.vm, 'updatePageContainerClass');

        wrapper.vm.handleWindowResize();

        expect(wrapper.vm.updatePageContainerClass).toHaveBeenCalled();
      });
    });
  });

  describe('template', () => {
    describe('sidebar expanded', () => {
      beforeEach(() => {
        jest.spyOn(Cookies, 'get').mockReturnValue(false);
        jest.spyOn(bp, 'isDesktop').mockReturnValue(true);

        wrapper = createComponent();
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
      beforeEach(() => {
        jest.spyOn(Cookies, 'get').mockReturnValue(true);

        wrapper = createComponent();
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
      wrapper = createComponent();

      const sidebarItemsEl = wrapper.find('[data-testid="sidebar-items"]');

      expect(sidebarItemsEl.exists()).toBe(true);
      expect(sidebarItemsEl.find('button.js-todo').exists()).toBe(true);
    });
  });

  describe('with slot', () => {});
});
