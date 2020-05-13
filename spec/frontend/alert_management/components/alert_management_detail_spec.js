import { shallowMount } from '@vue/test-utils';
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
import AlertDetails from '~/alert_management/components/alert_details.vue';

describe('AlertDetails', () => {
  let wrapper;
  const newIssuePath = 'root/alerts/-/issues/new';

  function mountComponent({
    data = { alert: {} },
    createIssueFromAlertEnabled = false,
    loading = false,
  } = {}) {
    wrapper = shallowMount(AlertDetails, {
      propsData: {
        alertId: 'alertId',
        projectPath: 'projectPath',
        newIssuePath,
      },
      data() {
        return data;
      },
      provide: {
        glFeatures: { createIssueFromAlertEnabled },
      },
      mocks: {
        $apollo: {
          queries: {
            alert: {
              loading,
            },
          },
        },
      },
    });
  }

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
    }
  });

  const findCreatedIssueBtn = () => wrapper.find('[data-testid="createIssueBtn"]');

  describe('Alert details', () => {
    describe('when alert is null', () => {
      beforeEach(() => {
        mountComponent({ data: { alert: null } });
      });

      it('shows an empty state', () => {
        expect(wrapper.find('[data-testid="alertDetailsTabs"]').exists()).toBe(false);
      });
    });

    describe('when alert is present', () => {
      beforeEach(() => {
        mountComponent();
      });

      it('renders a tab with overview information', () => {
        expect(wrapper.find('[data-testid="overviewTab"]').exists()).toBe(true);
      });

      it('renders a tab with full alert information', () => {
        expect(wrapper.find('[data-testid="fullDetailsTab"]').exists()).toBe(true);
      });

      it('renders alert details', () => {
        expect(wrapper.find('[data-testid="startTimeItem"]').exists()).toBe(true);
      });
    });

    it('renders a status dropdown containing three items', () => {
      expect(wrapper.findAll('[data-testid="statusDropdownItem"]').length).toBe(3);
    });

    describe('Create issue from alert', () => {
      describe('createIssueFromAlertEnabled feature flag enabled', () => {
        it('should display a button that links to new issue page', () => {
          mountComponent({ createIssueFromAlertEnabled: true });
          expect(findCreatedIssueBtn().exists()).toBe(true);
          expect(findCreatedIssueBtn().attributes('href')).toBe(newIssuePath);
        });
      });

      describe('createIssueFromAlertEnabled feature flag disabled', () => {
        it('should display a button that links to a new issue page', () => {
          mountComponent({ createIssueFromAlertEnabled: false });
          expect(findCreatedIssueBtn().exists()).toBe(false);
        });
      });
    });

    describe('loading state', () => {
      beforeEach(() => {
        mountComponent({ loading: true });
      });

      it('displays a loading state when loading', () => {
        expect(wrapper.find(GlLoadingIcon).exists()).toBe(true);
      });
    });

    describe('error state', () => {
      it('displays a error state correctly', () => {
        mountComponent({ data: { errored: true } });
        expect(wrapper.find(GlAlert).exists()).toBe(true);
      });

      it('does not display an error when dismissed', () => {
        mountComponent({ data: { errored: true, isErrorDismissed: true } });
        expect(wrapper.find(GlAlert).exists()).toBe(false);
      });
    });
  });
});
