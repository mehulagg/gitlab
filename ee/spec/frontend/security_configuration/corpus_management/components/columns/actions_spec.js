import { GlButton, GlModal } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import { nextTick } from 'vue';
import Actions from 'ee/security_configuration/corpus_management/components/columns/actions.vue';
import { s__ } from '~/locale';
import { corpuses } from '../../mock_data';

describe('Action buttons', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = {
      corpus: corpuses[0],
    };
    wrapper = mountFn(Actions, {
      propsData: defaultProps,
      ...options,
    });
  };

  const createComponent = createComponentFactory();
  const createMountedComponent = createComponentFactory(mount);

  afterEach(() => {
    wrapper.destroy();
  });

  describe('corpus management', () => {
    it('renders the action buttons', () => {
      createComponent();
      expect(wrapper.findAll(GlButton).length).toBe(2);
    });

    describe('delete confirmation modal', () => {
      beforeEach(() => {
        createMountedComponent();
        wrapper.findComponents(GlButton).at(1).trigger('click');
        return nextTick();
      });

      it('shows the delete confirmation', () => {
        const deleteModal = wrapper.findComponent(GlModal);
        // This fails
        expect(deleteModal.text()).toBe(
          s__('Corpus Management|Are you sure you want to delete the corpus?'),
        );
      });
    });
  });
});
