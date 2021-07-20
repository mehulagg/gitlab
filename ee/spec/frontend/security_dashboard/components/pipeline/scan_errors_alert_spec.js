import { GlAccordion, GlAccordionItem, GlAlert, GlButton, GlSprintf } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import PipelineScanErrorsAlert from 'ee/security_dashboard/components/pipeline/scan_errors_alert.vue';
import { trimText } from 'helpers/text_helper';
import { extendedWrapper } from 'helpers/vue_test_utils_helper';

const TEST_HELP_PAGE_LINK = 'http://help.com';
const TEST_SCANS_WITH_ERRORS = [
  { errors: ['scanner 1 - error 1', 'scanner 1 - error 2'], name: 'foo' },
  { errors: ['scanner 1 - error 3', 'scanner 1 - error 4'], name: 'bar' },
  { errors: ['scanner 3 - error 1', 'scanner 3 - error 2'], name: 'baz' },
];

describe('ee/security_dashboard/components/pipeline_scan_errors_alert.vue', () => {
  let wrapper;

  const createWrapper = () =>
    extendedWrapper(
      shallowMount(PipelineScanErrorsAlert, {
        propsData: {
          scans: TEST_SCANS_WITH_ERRORS,
        },
        provide: {
          securityReportHelpPageLink: TEST_HELP_PAGE_LINK,
        },
        stubs: {
          GlSprintf,
        },
      }),
    );

  const findAccordion = () => wrapper.findComponent(GlAccordion);
  const findAllAccordionItems = () => wrapper.findAllComponents(GlAccordionItem);
  const findAccordionItemsWithTitle = (title) =>
    findAllAccordionItems().filter((item) => item.props('title') === title);
  const findAlert = () => wrapper.findComponent(GlAlert);
  const findErrorList = () => wrapper.findByRole('list');
  const findHelpPageLink = () => wrapper.findComponent(GlButton);

  afterEach(() => {
    wrapper.destroy();
  });

  beforeEach(() => {
    wrapper = createWrapper();
  });

  it('shows a non-dismissible error alert', () => {
    expect(findAlert().props()).toMatchObject({
      variant: 'danger',
      dismissible: false,
    });
  });

  it('shows the correct title for the error alert', () => {
    expect(findAlert().text()).toContain('Error parsing security reports');
  });

  it('shows the correct description for the error-alert', () => {
    expect(trimText(findAlert().text())).toContain(
      'The security reports below contain one or more vulnerability findings that could not be parsed and were not recorded. Download the artifacts in the job output to investigate. Ensure any security report created conforms to the relevant JSON schema',
    );
  });

  it('links to the security-report help page', () => {
    expect(findHelpPageLink().attributes('href')).toBe(TEST_HELP_PAGE_LINK);
  });

  describe('errors details', () => {
    it('shows an accordion containing a list of scans with errors', () => {
      expect(findAccordion().exists()).toBe(true);
      expect(findAllAccordionItems()).toHaveLength(TEST_SCANS_WITH_ERRORS.length);
    });

    it('shows a list containing details about each error', () => {
      expect(findErrorList().exists()).toBe(true);
    });

    describe.each(TEST_SCANS_WITH_ERRORS)('scan errors', (scan) => {
      const currentScanTitle = `${scan.name} (${scan.errors.length})`;
      const findAllAccordionItemsForCurrentScan = () =>
        findAccordionItemsWithTitle(currentScanTitle);
      const findAccordionItemForCurrentScan = () => findAllAccordionItemsForCurrentScan().at(0);

      it(`contains an accordion item with the correct title for scan "${scan.name}"`, () => {
        expect(findAllAccordionItemsForCurrentScan()).toHaveLength(1);
      });

      it(`contains a detailed list of errors for scan "${scan.name}}"`, () => {
        expect(findAccordionItemForCurrentScan().find('ul').exists()).toBe(true);
        expect(findAccordionItemForCurrentScan().findAll('li')).toHaveLength(scan.errors.length);
      });
    });
  });
});
