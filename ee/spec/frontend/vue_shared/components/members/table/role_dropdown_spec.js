import { shallowMount } from '@vue/test-utils';
import { GlDropdown } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import { member } from 'jest/vue_shared/components/members/mock_data';
import LdapDropdownItem from 'ee/vue_shared/components/members/ldap/ldap_dropdown_item.vue';
import RoleDropdown from '~/vue_shared/components/members/table/role_dropdown.vue';

describe('RoleDropdown', () => {
  let wrapper;

  const createComponent = (propsData = {}) => {
    wrapper = shallowMount(RoleDropdown, {
      propsData: {
        member,
        permissions: {},
        ...propsData,
      },
    });

    return waitForPromises();
  };

  const findDropdown = () => wrapper.find(GlDropdown);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('when member has `canOverride` permissions', () => {
    describe('when member is overridden', () => {
      it('renders LDAP dropdown item', async () => {
        await createComponent({
          permissions: {
            canOverride: true,
          },
          member: { ...member, isOverridden: true },
        });

        expect(wrapper.find(LdapDropdownItem).exists()).toBe(true);
      });
    });

    describe('when member is not overridden', () => {
      it('disables dropdown', async () => {
        await createComponent({
          permissions: {
            canOverride: true,
          },
          member: { ...member, isOverridden: false },
        });

        expect(findDropdown().attributes('disabled')).toBe('true');
      });
    });
  });

  describe('when member does not have `canOverride` permissions', () => {
    it('does not render LDAP dropdown item', async () => {
      await createComponent({
        permissions: {
          canOverride: false,
        },
      });

      expect(wrapper.find(LdapDropdownItem).exists()).toBe(false);
    });
  });
});
