import { mount } from '@vue/test-utils';
import EnvironmentAlert from 'ee/environments/components/environment_alert.vue';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';
import { useFakeDate } from 'helpers/fake_date';

describe('Environment Alert', () => {
  let wrapper;
  const DEFAULT_PROVIDE = { projectPath: 'test-org/test' };
  const DEFAULT_PROPS = { environment: { name: 'staging' } };

  useFakeDate();

  const factory = (props = {}, provide = {}) => {
    wrapper = mount(EnvironmentAlert, {
      propsData: {
        ...DEFAULT_PROPS,
        ...props,
      },
      provide: {
        ...DEFAULT_PROVIDE,
        ...provide,
      },
    });
  };

  beforeEach(() => {
    factory();
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('has alert', () => {
    beforeEach(() => {
      wrapper.setData({
        alert: {
          severity: 'CRITICAL',
          title: 'alert title',
          prometheusAlert: { humanizedText: '>0.1% jest' },
          detailsUrl: '/alert/details',
          startedAt: new Date(),
        },
      });
    });

    it('should display the alert details', () => {
      const text = wrapper.text();
      expect(text).toContain('Critical');
      expect(text).toContain('alert title >0.1% jest.');
      expect(text).toContain('View Details');
      expect(text).toContain('just now');
    });

    it('should link to the details of the alert', () => {
      const link = wrapper.find('[data-testid="alert-link"]');
      expect(link.text()).toBe('View Details');
      expect(link.attributes('href')).toBe('/alert/details');
    });

    it('should show a severity badge', () => {
      expect(wrapper.find(SeverityBadge).props('severity')).toBe('CRITICAL');
    });
  });

  describe('has no alert', () => {
    it('should display nothing', () => {
      expect(wrapper.find('[data-testid="alert"]').exists()).toBe(false);
    });
  });
});
