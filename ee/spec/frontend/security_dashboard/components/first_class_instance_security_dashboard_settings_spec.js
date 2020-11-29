import { GlAlert } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import FirstClassInstanceDashboardSettings from 'ee/security_dashboard/components/first_class_instance_security_dashboard_settings.vue';
import ProjectManager from 'ee/security_dashboard/components/first_class_project_manager/project_manager.vue';

describe('First Class Instance Dashboard Component', () => {
  let wrapper;

  const defaultMocks = ({ loading = false } = {}) => ({
    $apollo: { queries: { projects: { loading } } },
  });

  const findProjectManager = () => wrapper.find(ProjectManager);
  const findAlert = () => wrapper.find(GlAlert);

  const createWrapper = ({ mocks = defaultMocks(), data = {} }) => {
    return shallowMount(FirstClassInstanceDashboardSettings, {
      mocks,
      data() {
        return data;
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when there is no error', () => {
    beforeEach(() => {
      wrapper = createWrapper({});
    });

    it('displays the project manager', () => {
      expect(findProjectManager().exists()).toBe(true);
    });

    it('does not render the alert component', () => {
      expect(findAlert().exists()).toBe(false);
    });
  });

  describe('when there is a loading error', () => {
    beforeEach(() => {
      wrapper = createWrapper({ data: { hasError: true } });
    });

    it('does not display the project manager', () => {
      expect(findProjectManager().exists()).toBe(false);
    });

    it('renders the alert component', () => {
      expect(findAlert().text()).toBe('An error occurred while retrieving projects.');
    });
  });
});
