import { mount } from '@vue/test-utils';
import ExperimentComponent from '~/experimentation/components/experiment.vue';
import { isExperimentVariant } from '~/experimentation/utils';

jest.mock('~/experimentation/utils', () => ({ isExperimentVariant: jest.fn() }));

const defaultProps = { name: 'experiment' };
const defaultSlots = {
  control: `<p>Control</p>`,
  candidate: `<p>Candidate</p>`,
};

const mockVariant = (expectedVariant) => {
  isExperimentVariant.mockImplementation((_, variant) => variant == expectedVariant);
};

describe('ExperimentComponent', () => {
  let wrapper;

  const createComponent = (props = defaultProps, slots = defaultSlots) => {
    wrapper = mount(ExperimentComponent, { props, slots });
  };

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders control when it is the active variant', () => {
    mockVariant('control');

    createComponent();

    expect(wrapper.text()).toContain('Control');
  });

  it('renders candidate when it is the active variant', () => {
    mockVariant('candidate');

    createComponent();

    expect(wrapper.text()).toContain('Candidate');
  });

  it('renders first slot when no variant is active', () => {
    mockVariant('non-existing-variant');

    createComponent();

    expect(wrapper.text()).toContain('Control');
  });
});
