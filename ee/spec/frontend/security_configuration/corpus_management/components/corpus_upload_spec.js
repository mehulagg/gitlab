import { GlButton } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import CorpusUpload from 'ee/security_configuration/corpus_management/components/corpus_upload.vue';

describe('Corpus Upload', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = { totalSize: 4e8 };
    wrapper = mountFn(CorpusUpload, {
      propsData: defaultProps,
      ...options,
    });
  };

  const createComponent = createComponentFactory();

  afterEach(() => {
    wrapper.destroy();
  });

  describe('component', () => {
    it('renders header', () => {
      createComponent();
      expect(wrapper.findComponent(GlButton).exists()).toBe(true);
      expect(wrapper.element).toMatchSnapshot();
    });

    it('calls the `uploadCorpus` callback on `new corpus` button click', async () => {
      createComponent({ stubs: { GlButton } });
      await wrapper.findComponent(GlButton).trigger('click');

      expect(wrapper.emitted().newcorpus).toEqual([[]]);
    });
  });
});
