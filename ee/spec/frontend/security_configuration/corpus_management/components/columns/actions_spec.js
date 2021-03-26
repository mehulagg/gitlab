import { GlButton, GlModal } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
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
        createComponent({ stubs: { GlModal } });
      });

      it('shows the delete confirmation', () => {
        const deleteModal = wrapper.findComponent(GlModal);

        expect(deleteModal.vm.$slots['modal-title'][0].text).toContain(
          s__('Corpus Management|Are you sure you want to delete the corpus?'),
        );
      });

      it('calls the deleteCorpus method', async () => {
        wrapper.findComponent(GlModal).vm.$emit('primary');
        await nextTick();

        expect(wrapper.emitted().delete).toBeTruthy();
      });
    });
  });
});
