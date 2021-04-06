import { shallowMount } from '@vue/test-utils';
import LearnGitlabSectionLink from '~/pages/projects/learn_gitlab/components/learn_gitlab_section_link.vue';

const defaultAction = 'gitWrite';
const defaultProps = {
  title: 'Create Repository',
  description: 'Some description',
  url: 'https://example.com',
  completed: false,
};

describe('Learn GitLab Section Link', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const createWrapper = (props = {}) => {
    wrapper = shallowMount(LearnGitlabSectionLink, {
      propsData: { action: defaultAction, value: { ...defaultProps, ...props } },
    });
  };

  it('renders correctly', () => {
    createWrapper({ completed: false });

    expect(wrapper.element).toMatchSnapshot();
  });

  it('renders no icon when not completed', () => {
    createWrapper({ completed: false });

    expect(wrapper.find('[data-testid="completed-icon"]').exists()).toBe(false);
  });

  it('renders the completion icon when completed', () => {
    createWrapper({ completed: true });

    expect(wrapper.find('[data-testid="completed-icon"]').exists()).toBe(true);
  });
});
