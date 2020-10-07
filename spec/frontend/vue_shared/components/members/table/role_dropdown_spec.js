import { mount, createWrapper } from '@vue/test-utils';
import { nextTick } from 'vue';
import { within } from '@testing-library/dom';
import { GlDropdown } from '@gitlab/ui';
import { GlBreakpointInstance as bp } from '@gitlab/ui/dist/utils';
import RoleDropdown from '~/vue_shared/components/members/table/role_dropdown.vue';
import { member } from '../mock_data';

describe('RoleDropdown', () => {
  let wrapper;

  const createComponent = (propsData = {}) => {
    wrapper = mount(RoleDropdown, {
      propsData: {
        member,
        ...propsData,
      },
    });
  };

  const getDropdownMenu = () => within(wrapper.element).getByRole('menu');
  const getByTextInDropdownMenu = text => createWrapper(within(getDropdownMenu()).getByText(text));
  const getDropdownToggle = () => wrapper.find('button[aria-haspopup="true"]');

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when dropdown is open', () => {
    beforeEach(done => {
      createComponent();

      getDropdownToggle().trigger('click');
      wrapper.vm.$root.$on('bv::dropdown::shown', () => {
        done();
      });
    });

    it('renders all valid roles', () => {
      Object.keys(member.validRoles).forEach(role => {
        expect(getByTextInDropdownMenu(role).exists()).toBe(true);
      });
    });

    it('renders dropdown header', () => {
      expect(getByTextInDropdownMenu('Change permissions').exists()).toBe(true);
    });

    it('updates dropdown toggle with selected role', async () => {
      expect(getDropdownToggle().text()).toBe('Owner');

      getByTextInDropdownMenu('Guest').trigger('click');
      await nextTick();

      expect(getDropdownToggle().text()).toBe('Guest');
    });
  });

  it("sets initial dropdown toggle value to member's role", () => {
    createComponent();

    expect(getDropdownToggle().text()).toBe('Owner');
  });

  it('sets the dropdown alignment to right on mobile', () => {
    jest.spyOn(bp, 'isDesktop').mockReturnValue(false);
    createComponent();

    const dropdown = wrapper.find(GlDropdown);

    expect(dropdown.attributes('right')).toBe('true');
  });

  it('sets the dropdown alignment to left on desktop', () => {
    jest.spyOn(bp, 'isDesktop').mockReturnValue(true);
    createComponent();

    const dropdown = wrapper.find(GlDropdown);

    expect(dropdown.attributes('right')).toBeUndefined();
  });
});
