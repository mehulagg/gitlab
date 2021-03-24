import { GlButton, GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Actions from 'ee/security_configuration/corpus_management/components/columns/actions.vue';
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

  afterEach(() => {
    wrapper.destroy();
  });

  describe('corpus management', () => {
    it('renders the action buttons', () => {
      createComponent();
      expect(wrapper.findAll(GlButton).length).toBe(2);
    });

    it('sets the modal primary button callback to deleteCorpus', () => {
      createComponent();
      /* eslint-disable no-underscore-dangle */
      const modalFunc = wrapper.findComponent(GlModal).vm._events.primary[0].fns;
      const destroyFunc = wrapper.vm.deleteCorpus;

      expect(modalFunc).toEqual(destroyFunc);
    });
  });
});
