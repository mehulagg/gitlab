import { shallowMount } from '@vue/test-utils';
import Cookies from 'js-cookie';

import IssuableShowRoot from '~/issuable_show/components/issuable_show_root.vue';

import IssuableHeader from '~/issuable_show/components/issuable_header.vue';
import IssuableBody from '~/issuable_show/components/issuable_body.vue';
import IssuableSidebar from '~/issuable_sidebar/components/issuable_sidebar_root.vue';

import { mockIssuableShowProps, mockIssuable } from '../mock_data';

const createComponent = (propsData = mockIssuableShowProps) =>
  shallowMount(IssuableShowRoot, {
    propsData,
    stubs: {
      IssuableHeader,
      IssuableBody,
      IssuableSidebar,
    },
    slots: {
      'status-badge': 'Open',
      'header-actions': `
        <button class="js-close">Close issuable</button>
        <a class="js-new" href="/gitlab-org/gitlab-shell/-/issues/new">New issuable</a>
      `,
      'edit-form-actions': `
        <button class="js-save">Save changes</button>
        <button class="js-cancel">Cancel</button>
      `,
      'right-sidebar-items': `
        <div class="js-todo">
          To Do <button class="js-add-todo">Add a To Do</button>
        </div>
      `,
    },
  });

describe('IssuableShowRoot', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('methods', () => {
    describe('handleSidebarToggle', () => {
      beforeEach(() => {
        setFixtures('<div class="layout-page"></div>');
        jest.spyOn(Cookies, 'set').mockImplementation(jest.fn());
      });

      it.each`
        expanded | sidebarStatusClass
        ${true}  | ${'right-sidebar-expanded'}
        ${false} | ${'right-sidebar-collapsed'}
      `(
        'set class $sidebarStatusClass to container element when `expanded` param is $expanded',
        async ({ expanded, sidebarStatusClass }) => {
          wrapper.vm.handleSidebarToggle({
            expanded,
            manual: false,
          });

          await wrapper.vm.$nextTick();

          expect(
            document.querySelector('.layout-page').classList.contains(sidebarStatusClass),
          ).toBe(true);
        },
      );

      it.each`
        expanded | cookieValue
        ${true}  | ${false}
        ${false} | ${true}
      `(
        'sets value of cookie "collapsed_gutter" to $cookieValue when `expanded` param is $expanded',
        async ({ expanded, cookieValue }) => {
          wrapper.vm.handleSidebarToggle({
            expanded,
            manual: true,
          });

          await wrapper.vm.$nextTick();

          expect(wrapper.vm.rightSidebarExpanded).toBe(expanded);
          expect(Cookies.set).toHaveBeenCalledWith('collapsed_gutter', cookieValue);
        },
      );

      it('emits event `sidebar-toggle` event on the component', () => {
        wrapper.vm.handleSidebarToggle({
          expanded: true,
          manual: false,
        });

        expect(wrapper.emitted('sidebar-toggle')).toBeTruthy();
        expect(wrapper.emitted('sidebar-toggle')[0]).toEqual([true]);
      });
    });
  });

  describe('template', () => {
    const {
      statusBadgeClass,
      statusIcon,
      enableEdit,
      enableAutocomplete,
      editFormVisible,
      descriptionPreviewPath,
      descriptionHelpPath,
    } = mockIssuableShowProps;
    const { blocked, confidential, createdAt, author } = mockIssuable;

    it('renders component container element with class `issuable-show-container`', () => {
      expect(wrapper.classes()).toContain('issuable-show-container');
    });

    it('renders issuable-header component', () => {
      const issuableHeader = wrapper.find(IssuableHeader);

      expect(issuableHeader.exists()).toBe(true);
      expect(issuableHeader.props()).toMatchObject({
        statusBadgeClass,
        statusIcon,
        blocked,
        confidential,
        createdAt,
        author,
      });
      expect(issuableHeader.find('.issuable-status-box').text()).toContain('Open');
      expect(issuableHeader.find('.detail-page-header-actions button.js-close').exists()).toBe(
        true,
      );
      expect(issuableHeader.find('.detail-page-header-actions a.js-new').exists()).toBe(true);
    });

    it('renders issuable-body component', () => {
      const issuableBody = wrapper.find(IssuableBody);

      expect(issuableBody.exists()).toBe(true);
      expect(issuableBody.props()).toMatchObject({
        issuable: mockIssuable,
        statusBadgeClass,
        statusIcon,
        enableEdit,
        enableAutocomplete,
        editFormVisible,
        descriptionPreviewPath,
        descriptionHelpPath,
      });
    });

    it('renders issuable-sidebar component', () => {
      jest.spyOn(Cookies, 'get').mockReturnValue('true');
      const issuableSidebar = wrapper.find(IssuableSidebar);

      expect(issuableSidebar.exists()).toBe(true);
      expect(issuableSidebar.props('expanded')).toBe(true);
    });

    describe('events', () => {
      it('component emits `edit-issuable` event bubbled via issuable-body', () => {
        const issuableBody = wrapper.find(IssuableBody);

        issuableBody.vm.$emit('edit-issuable');

        expect(wrapper.emitted('edit-issuable')).toBeTruthy();
      });

      it('issuable-sidebar component calls `handleSidebarToggle` on `sidebar-toggle` event', () => {
        jest.spyOn(wrapper.vm, 'handleSidebarToggle').mockImplementation(jest.fn);
        const issuableSidebar = wrapper.find(IssuableSidebar);

        issuableSidebar.vm.$emit('sidebar-toggle', true);

        expect(wrapper.emitted('sidebar-toggle')).toBeTruthy();
      });
    });
  });
});
