import { shallowMount } from '@vue/test-utils';
import { GlDropdownDivider } from '@gitlab/ui';
import AdminUserActions from '~/admin/users/components/user_actions.vue';
import { generateUserPaths } from '~/admin/users/utils';
import {
  ACTION_COMPONENTS,
  DELETE_ACTION_COMPONENTS,
  I18N_USER_ACTIONS,
} from '~/admin/users/constants';
import { capitalizeFirstCharacter } from '~/lib/utils/text_utility';

import { users, paths } from '../mock_data';

const BLOCK = 'block';
const UNBLOCK = 'unblock';
const EDIT = 'edit';
const LDAP = 'ldapBlocked';
const DELETE = 'delete';
const DELETE_WITH_CONTRIBUTIONS = 'deleteWithContributions';
const UNLOCK = 'unlock';
const ACTIVATE = 'activate';
const DEACTIVATE = 'deactivate';
const REJECT = 'reject';
const APPROVE = 'approve';

describe('AdminUserActions component', () => {
  let wrapper;
  const user = users[0];
  const userPaths = generateUserPaths(paths, user.username);

  const findEditButton = () => wrapper.find('[data-testid="edit"]');
  const findActionsDropdown = () => wrapper.find('[data-testid="actions"');
  const findDropdownDivider = () => wrapper.find(GlDropdownDivider);

  const initComponent = ({ actions = [] } = {}) => {
    wrapper = shallowMount(AdminUserActions, {
      propsData: {
        user: {
          ...user,
          actions,
        },
        paths,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('edit button', () => {
    describe('when the user has an edit action attached', () => {
      beforeEach(() => {
        initComponent({ actions: [EDIT] });
      });

      it('renders the edit button linking to the user edit path', () => {
        expect(findEditButton().exists()).toBe(true);
        expect(findEditButton().attributes('href')).toBe(userPaths.edit);
      });
    });

    describe('when there is no edit action attached to the user', () => {
      beforeEach(() => {
        initComponent({ actions: [] });
      });

      it('does not render the edit button linking to the user edit path', () => {
        expect(findEditButton().exists()).toBe(false);
      });
    });
  });

  describe('actions dropdown', () => {
    describe('when there are actions', () => {
      const actions = [EDIT, BLOCK];

      beforeEach(() => {
        initComponent({ actions });
      });

      it('renders the actions dropdown', () => {
        expect(findActionsDropdown().exists()).toBe(true);
      });

      describe('when there are actions that do not require confirmation', () => {
        const linkActions = [REJECT, APPROVE];

        beforeEach(() => {
          initComponent({ actions: linkActions });
        });

        it.each(linkActions)('renders a dropdown item with a link for "%s"', (action) => {
          const component = wrapper.find(`[data-testid="${action}"]`);

          expect(component.exists()).toBe(true);
          expect(component.attributes('href')).toBe(userPaths[action]);
          expect(component.text()).toBe(I18N_USER_ACTIONS[action]);
        });
      });

      describe('when there are actions that require confirmation', () => {
        const confirmationActions = [ACTIVATE, BLOCK, DEACTIVATE, UNLOCK, UNBLOCK];

        beforeEach(() => {
          initComponent({ actions: confirmationActions });
        });

        it.each(confirmationActions)('renders an action component item for "%s"', (action) => {
          const component = wrapper.find(ACTION_COMPONENTS[capitalizeFirstCharacter(action)]);

          expect(component.exists()).toBe(true);
          expect(component.props('username')).toBe(user.name);
          expect(component.props('path')).toEqual(userPaths[action]);
          expect(component.text()).toBe(I18N_USER_ACTIONS[action]);
        });
      });

      describe('when there is a LDAP action', () => {
        beforeEach(() => {
          initComponent({ actions: [LDAP] });
        });

        it('renders the LDAP dropdown item without a link', () => {
          const dropdownAction = wrapper.find(`[data-testid="${LDAP}"]`);
          expect(dropdownAction.exists()).toBe(true);
          expect(dropdownAction.attributes('href')).toBe(undefined);
          expect(dropdownAction.text()).toBe(I18N_USER_ACTIONS[LDAP]);
        });
      });

      describe('when there is a delete action', () => {
        const deleteActions = [DELETE, DELETE_WITH_CONTRIBUTIONS];

        beforeEach(() => {
          initComponent({ actions: [BLOCK, ...deleteActions] });
        });

        it('renders a dropdown divider', () => {
          expect(findDropdownDivider().exists()).toBe(true);
        });

        it('only renders delete dropdown items for actions containing the word "delete"', () => {
          const { length } = wrapper.findAll(`[data-testid*="delete-"]`);
          expect(length).toBe(deleteActions.length);
        });

        it.each(deleteActions)('renders a delete action component item for "%s"', (action) => {
          const component = wrapper.find(
            DELETE_ACTION_COMPONENTS[capitalizeFirstCharacter(action)],
          );

          expect(component.exists()).toBe(true);
          expect(component.props('username')).toBe(user.name);
          expect(component.props('paths')).toEqual(userPaths);
          expect(component.text()).toBe(I18N_USER_ACTIONS[action]);
        });
      });

      describe('when there are no delete actions', () => {
        it('does not render a dropdown divider', () => {
          expect(findDropdownDivider().exists()).toBe(false);
        });

        it('does not render a delete dropdown item', () => {
          const anyDeleteAction = wrapper.find(`[data-testid*="delete-"]`);
          expect(anyDeleteAction.exists()).toBe(false);
        });
      });
    });

    describe('when there are no actions', () => {
      beforeEach(() => {
        initComponent({ actions: [] });
      });

      it('does not render the actions dropdown', () => {
        expect(findActionsDropdown().exists()).toBe(false);
      });
    });
  });
});
