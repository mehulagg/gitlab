import { nextTick } from 'vue';
import { shallowMount } from '@vue/test-utils';
import { GlDropdownItem } from '@gitlab/ui';
import { kebabCase } from 'lodash';
import { ACTION_COMPONENTS, DELETE_ACTION_COMPONENTS } from '~/admin/users/constants';
import SharedDeleteAction from '~/admin/users/components/actions/shared/shared_delete_action.vue';

describe('Action components', () => {
  let wrapper;

  const findDropdownItem = () => wrapper.find(GlDropdownItem);

  const initComponent = ({ component, props, stubs = {} } = {}) => {
    wrapper = shallowMount(component, {
      propsData: {
        ...props,
      },
      stubs,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('ACTION_COMPONENTS', () => {
    const actions = Object.keys(ACTION_COMPONENTS);

    it.each(actions)('renders a dropdown item for "%s"', async (action) => {
      initComponent({
        component: ACTION_COMPONENTS[action],
        props: {
          username: 'John Doe',
          path: '/test',
        },
      });

      await nextTick();

      const div = wrapper.find('div');
      expect(div.attributes('data-path')).toBe('/test');
      expect(div.attributes('data-modal-attributes')).toContain('John Doe');
      expect(findDropdownItem().exists()).toBe(true);
    });
  });

  describe('DELETE_ACTION_COMPONENTS', () => {
    const deleteActions = Object.keys(DELETE_ACTION_COMPONENTS);

    it.each(deleteActions)('renders a dropdown item for "%s"', async (action) => {
      initComponent({
        component: DELETE_ACTION_COMPONENTS[action],
        props: {
          username: 'John Doe',
          paths: {
            delete: '/delete',
            block: '/block',
          },
        },
        stubs: { SharedDeleteAction },
      });

      await nextTick();

      const sharedAction = wrapper.find(SharedDeleteAction);

      expect(sharedAction.exists()).toBe(true);
      expect(sharedAction.attributes('data-block-user-url')).toBe('/block');
      expect(sharedAction.attributes('data-delete-user-url')).toBe('/delete');
      expect(sharedAction.attributes('data-gl-modal-action')).toBe(kebabCase(action));
      expect(sharedAction.attributes('data-username')).toBe('John Doe');
      expect(findDropdownItem().exists()).toBe(true);
    });
  });
});
