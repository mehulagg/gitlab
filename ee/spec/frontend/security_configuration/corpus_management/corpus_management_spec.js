import { shallowMount } from '@vue/test-utils';
import CorpusManagement from 'ee/security_configuration/corpus_management/components/corpus_management.vue';

const TEST_PROJECT_FULL_PATH = '/namespace/project';

describe('EE - CorpusManagement', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = {
      projectFullPath: TEST_PROJECT_FULL_PATH,
    };
    wrapper = mountFn(CorpusManagement, {
      propsData: defaultProps,
      ...options,
    });
  };

  const createComponent = createComponentFactory();

  afterEach(() => {
    wrapper.destroy();
  });

  describe('corpus management', () => {
    it('bootstraps and renders the component', () => {
      createComponent();
      expect(wrapper.find(CorpusManagement).exists()).toBe(true);
    });
  });
});
