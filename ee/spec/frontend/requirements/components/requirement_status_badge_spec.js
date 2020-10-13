import { shallowMount } from '@vue/test-utils';

import { GlBadge, GlIcon, GlTooltip } from '@gitlab/ui';
import RequirementStatusBadge from 'ee/requirements/components/requirement_status_badge.vue';

import { mockTestReport, mockTestReportFailed, mockTestReportMissing } from '../mock_data';

const createComponent = (testReport = mockTestReport) =>
  shallowMount(RequirementStatusBadge, {
    propsData: {
      testReport,
    },
  });

describe('RequirementStatusBadge', () => {
  let wrapper;

  beforeEach(() => {
    wrapper = createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('computed', () => {
    describe('testReportBadge', () => {
      it('returns object containing variant, icon, text and tooltipTitle when status is "PASSED"', () => {
        expect(wrapper.vm.testReportBadge).toEqual({
          variant: 'success',
          icon: 'status_success',
          text: 'satisfied',
          tooltipTitle: 'Passed on',
        });
      });

      it('returns object containing variant, icon, text and tooltipTitle when status is "FAILED"', () => {
        wrapper.setProps({
          testReport: mockTestReportFailed,
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.testReportBadge).toEqual({
            variant: 'danger',
            icon: 'status_failed',
            text: 'failed',
            tooltipTitle: 'Failed on',
          });
        });
      });

      it('returns object containing variant, icon, text and tooltipTitle when status missing', () => {
        wrapper.setProps({
          testReport: mockTestReportMissing,
        });

        return wrapper.vm.$nextTick(() => {
          expect(wrapper.vm.testReportBadge).toEqual({
            variant: 'warning',
            icon: 'status_warning',
            text: 'missing',
            tooltipTitle: '',
          });
        });
      });
    });
  });

  describe('template', () => {
    it('renders GlBadge component', () => {
      const badgeEl = wrapper.find(GlBadge);

      expect(badgeEl.exists()).toBe(true);
      expect(badgeEl.props('variant')).toBe('success');
      expect(badgeEl.text()).toBe('satisfied');
      expect(badgeEl.find(GlIcon).exists()).toBe(true);
      expect(badgeEl.find(GlIcon).props('name')).toBe('status_success');
    });

    it('renders GlTooltip component', () => {
      const tooltipEl = wrapper.find(GlTooltip);

      expect(tooltipEl.exists()).toBe(true);
      expect(tooltipEl.find('b').text()).toBe('Passed on');
      expect(tooltipEl.find('div').text()).toBe('Jun 4, 2020 10:55am GMT+0000');
    });
  });
});
