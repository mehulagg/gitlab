import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Name from 'ee/security_configuration/corpus_management/components/columns/name.vue';
import { corpuses } from '../../mock_data';

describe('Name', () => {
  let wrapper;

  const createComponentFactory = (mountFn = shallowMount) => (options = {}) => {
    const defaultProps = {
      corpus: corpuses[0],
    };
    wrapper = mountFn(Name, {
      propsData: defaultProps,
      ...options,
    });
  };

  const createComponent = createComponentFactory();

  afterEach(() => {
    wrapper.destroy();
  });

  describe('component', () => {
    it('renders name with correct file size', () => {
      createComponent();
      const name = wrapper.find('[data-testid="corpus-name"]');
      expect(name.element).toMatchSnapshot();
    });

    it('renders the latest job', () => {
      createComponent();
      const name = wrapper.find('[data-testid="latest-job"]');
      expect(wrapper.findComponent(GlLink).exists()).toBe(true);
      expect(name.element).toMatchSnapshot();
    });

    describe('without job path', () => {
      it('renders a - string instead of a link', () => {
        createComponent({ propsData: { corpus: corpuses[2] } });
        const name = wrapper.find('[data-testid="latest-job"]');
        expect(wrapper.findComponent(GlLink).exists()).toBe(false);
        expect(name.element).toMatchSnapshot();
      });
    });
  });
});
