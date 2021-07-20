import { mount } from '@vue/test-utils';
import DashboardHasNoVulnerabilities from 'ee/security_dashboard/components/shared/empty_states/dashboard_has_no_vulnerabilities.vue';

describe('dashboard has no vulnerabilities empty state', () => {
  let wrapper;
  const emptyStateSvgPath = '/placeholder.svg';
  const dashboardDocumentation = '/path/to/dashboard/documentation';

  const createWrapper = () =>
    mount(DashboardHasNoVulnerabilities, {
      provide: {
        emptyStateSvgPath,
        dashboardDocumentation,
      },
    });

  beforeEach(() => {
    wrapper = createWrapper();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('matches snapshot', () => {
    expect(wrapper.html()).toMatchSnapshot();
  });
});
