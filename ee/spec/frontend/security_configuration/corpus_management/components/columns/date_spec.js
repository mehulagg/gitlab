import { shallowMount } from '@vue/test-utils';
import DateComponent from 'ee/security_configuration/corpus_management/components/columns/date.vue';

describe('Date', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = { date: new Date(2021, 1, 17) };
    wrapper = mountFn(DateComponent, {
      propsData: defaultProps,
      ...options,
    });
  };

  const createComponent = createComponentFactory();

  afterEach(() => {
    wrapper.destroy();
  });

  describe('component', () => {
    it('renders the action buttons', () => {
      createComponent();
      expect(wrapper.text()).toBe('2021-02-17');
    });
  });
});
