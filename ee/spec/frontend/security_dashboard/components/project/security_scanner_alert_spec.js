import { within, fireEvent } from '@testing-library/dom';
import { mount } from '@vue/test-utils';
import SecurityScannerAlert from 'ee/security_dashboard/components/project/security_scanner_alert.vue';

describe('EE Vulnerability Security Scanner Alert', () => {
  let wrapper;

  afterEach(() => {
    wrapper.destroy();
  });

  const createWrapper = ({ props = {}, provide = {} } = {}) => {
    const defaultProps = {
      notEnabledScanners: [],
      noPipelineRunScanners: [],
    };

    const defaultProvide = {
      notEnabledScannersHelpPath: '',
      noPipelineRunScannersHelpPath: '',
    };

    wrapper = mount(SecurityScannerAlert, {
      propsData: { ...defaultProps, ...props },
      provide: () => ({
        ...defaultProvide,
        ...provide,
      }),
    });
  };

  const withinWrapper = () => within(wrapper.element);
  const findAlert = () => withinWrapper().queryByRole('alert');
  const findById = (testId) => withinWrapper().getByTestId(testId);

  describe('container', () => {
    it('renders when disabled scanners are detected', () => {
      createWrapper({ props: { notEnabledScanners: ['SAST'], noPipelineRunScanners: [] } });

      expect(findAlert()).not.toBe(null);
    });

    it('renders when scanners without pipeline runs are detected', () => {
      createWrapper({ props: { notEnabledScanners: [], noPipelineRunScanners: ['DAST'] } });

      expect(findAlert()).not.toBe(null);
    });

    it('does not render when all scanners are enabled', () => {
      createWrapper({ props: { notEnabledScanners: [], noPipelineRunScanners: [] } });

      expect(findAlert()).toBe(null);
    });
  });

  describe('dismissal', () => {
    it('renders a button', () => {
      createWrapper({ props: { notEnabledScanners: ['SAST'] } });

      expect(withinWrapper().getByRole('button', { name: /dismiss/i })).not.toBe(null);
    });

    it('emits when the button is clicked', async () => {
      createWrapper({ props: { notEnabledScanners: ['SAST'] } });

      const dismissalButton = withinWrapper().getByRole('button', { name: /dismiss/i });
      expect(wrapper.emitted('dismiss')).toBe(undefined);

      await fireEvent.click(dismissalButton);

      expect(wrapper.emitted('dismiss')).toHaveLength(1);
    });
  });

  describe('alert text', () => {
    it.each`
      alertType          | givenScanners                                  | expectedTextContained
      ${'notEnabled'}    | ${{ notEnabledScanners: ['SAST'] }}            | ${'SAST is not enabled for this project'}
      ${'notEnabled'}    | ${{ notEnabledScanners: ['SAST', 'DAST'] }}    | ${'SAST, DAST are not enabled for this project'}
      ${'noPipelineRun'} | ${{ noPipelineRunScanners: ['SAST'] }}         | ${'SAST result is not available because a pipeline has not been run since it was enabled'}
      ${'noPipelineRun'} | ${{ noPipelineRunScanners: ['SAST', 'DAST'] }} | ${'SAST, DAST results are not available because a pipeline has not been run since it was enabled'}
    `('renders the correct warning', ({ alertType, givenScanners, expectedTextContained }) => {
      createWrapper({ props: { ...givenScanners } });

      expect(findById(alertType).innerText).toContain(expectedTextContained);
    });
  });

  describe('help links', () => {
    it.each`
      alertType          | linkText
      ${'notEnabled'}    | ${'More information'}
      ${'noPipelineRun'} | ${'Run a pipeline'}
    `('link for $alertType scanners renders correctly', ({ alertType, linkText }) => {
      createWrapper({
        props: {
          [`${alertType}Scanners`]: ['SAST'],
        },
        provide: {
          [`${alertType}ScannersHelpPath`]: 'http://foo.com/',
        },
      });

      expect(within(findById(alertType)).getByText(linkText).href).toBe('http://foo.com/');
    });
  });
});
