import { GlEmptyState } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DevopsAdoptionEmptyState from 'ee/analytics/devops_report/devops_adoption/components/devops_adoption_empty_state.vue';
import { DEVOPS_ADOPTION_STRINGS } from 'ee/analytics/devops_report/devops_adoption/constants';

const emptyStateSvgPath = 'illustrations/monitoring/getting_started.svg';

describe('DevopsAdoptionEmptyState', () => {
  let wrapper;

  const createComponent = (options = {}) => {
    const { stubs = {}, props = {} } = options;

    return shallowMount(DevopsAdoptionEmptyState, {
      provide: {
        emptyStateSvgPath,
      },
      propsData: {
        hasGroupsData: true,
        ...props,
      },
      stubs,
    });
  };

  const findEmptyState = () => wrapper.find(GlEmptyState);

  afterEach(() => {
    wrapper.destroy();
  });

  it('contains the correct svg', () => {
    wrapper = createComponent();

    expect(findEmptyState().props('svgPath')).toBe(emptyStateSvgPath);
  });

  it('contains the correct text', () => {
    wrapper = createComponent();

    const emptyState = findEmptyState();

    expect(emptyState.props('title')).toBe(DEVOPS_ADOPTION_STRINGS.emptyState.title);
    expect(emptyState.props('description')).toBe(DEVOPS_ADOPTION_STRINGS.emptyState.description);
  });
});
