import { shallowMount } from '@vue/test-utils';
import {
  CRITICAL,
  HIGH,
  MEDIUM,
  LOW,
} from 'ee/security_dashboard/store/modules/vulnerabilities/constants';
import SecurityIssueBody from 'ee/vue_shared/security_reports/components/security_issue_body.vue';
import SeverityBadge from 'ee/vue_shared/security_reports/components/severity_badge.vue';
import ReportLink from '~/reports/components/report_link.vue';
import { STATUS_FAILED } from '~/reports/constants';
import {
  sastParsedIssues,
  dockerReportParsed,
  parsedDast,
  dependencyScanningIssues,
  secretScanningParsedIssues,
} from '../mock_data';

describe('Security Issue Body', () => {
  let wrapper;

  const findReportLink = () => wrapper.find(ReportLink);

  const createComponent = issue => {
    wrapper = shallowMount(SecurityIssueBody, {
      propsData: {
        issue,
        status: STATUS_FAILED,
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each([
    ['SAST', sastParsedIssues[0], true, HIGH],
    ['DAST', parsedDast[0], false, LOW],
    ['Container Scanning', dockerReportParsed.vulnerabilities[0], false, MEDIUM],
    ['Dependency Scanning', dependencyScanningIssues[0], true],
    ['Secret Scanning', secretScanningParsedIssues[0], false, CRITICAL],
  ])('for a %s vulnerability', (name, vuln, hasReportLink, severity) => {
    beforeEach(() => {
      createComponent(vuln);
    });

    if (severity) {
      it(`shows SeverityBadge if severity is present`, () => {
        expect(wrapper.find(SeverityBadge).props('severity')).toBe(severity);
      });
    } else {
      it(`does not show SeverityBadge if severity is not present`, () => {
        expect(wrapper.find(SeverityBadge).exists()).toBe(false);
      });
    }

    it(`does ${hasReportLink ? '' : 'not '}render report link`, () => {
      expect(findReportLink().exists()).toBe(hasReportLink);
    });
  });
});
