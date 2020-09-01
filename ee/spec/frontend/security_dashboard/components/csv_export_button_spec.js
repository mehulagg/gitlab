import { shallowMount } from '@vue/test-utils';
import { GlLoadingIcon, GlIcon } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import { TEST_HOST } from 'helpers/test_constants';
import CsvExportButton, {
  STORAGE_KEY,
} from 'ee/security_dashboard/components/csv_export_button.vue';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import statusCodes from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';

jest.mock('~/flash');
jest.mock('~/lib/utils/datetime_utility', () => ({
  formatDate: () => '2020-04-12-10T14_32_35',
}));

const vulnerabilitiesExportEndpoint = `${TEST_HOST}/vulnerability_findings.csv`;

describe('Csv Button Export', () => {
  let mock;
  let wrapper;
  let spy;

  const issueUrl = 'https://gitlab.com/gitlab-org/gitlab/issues/197111';
  const findPopoverExternalLink = () => wrapper.find({ ref: 'popoverExternalLink' });
  const findPopoverButton = () => wrapper.find({ ref: 'popoverButton' });
  const findPopover = () => wrapper.find({ ref: 'popover' });
  const findCsvExportButton = () => wrapper.find({ ref: 'csvExportButton' });

  const createComponent = () => {
    return shallowMount(CsvExportButton, {
      propsData: {
        vulnerabilitiesExportEndpoint,
      },
      stubs: {
        GlIcon,
        GlLoadingIcon,
      },
    });
  };

  const setupMocksAndSpy = (statusLink, downloadLink, downloadAnchor, status = 'finished') => {
    mock
      .onPost(vulnerabilitiesExportEndpoint)
      .reply(statusCodes.ACCEPTED, { _links: { self: statusLink } });
    mock.onGet(statusLink).reply(() => {
      // We need to mock it at this stage because vue internally uses
      // document.createElement to mount the elements.
      spy = jest.spyOn(document, 'createElement').mockImplementationOnce(() => {
        // eslint-disable-next-line no-param-reassign
        downloadAnchor.click = jest.fn();
        return downloadAnchor;
      });

      return [statusCodes.OK, { _links: { download: downloadLink }, status }];
    });
  };

  afterEach(() => {
    wrapper.destroy();
    localStorage.removeItem(STORAGE_KEY);
  });

  describe('when the user sees the button for the first time', () => {
    beforeEach(() => {
      mock = new MockAdapter(axios);
      wrapper = createComponent();
    });

    it('renders correctly', () => {
      expect(findPopoverExternalLink().attributes('href')).toBe(issueUrl);
      expect(wrapper.text()).toContain('More information and share feedback');
      expect(wrapper.text()).toContain(
        'You can now export your security dashboard to a CSV report.',
      );
    });

    it('is a link that initiates the download and polls until the file is ready, and then opens the download in a new tab.', () => {
      const downloadAnchor = document.createElement('a');
      const statusLink = '/poll/until/complete';
      const downloadLink = '/link/to/download';

      setupMocksAndSpy(statusLink, downloadLink, downloadAnchor);

      findCsvExportButton().vm.$emit('click');

      return axios.waitForAll().then(() => {
        expect(spy).toHaveBeenCalledWith('a');
        expect(downloadAnchor.href).toContain(downloadLink);
        expect(downloadAnchor.getAttribute('download')).toBe(
          `csv-export-2020-04-12-10T14_32_35.csv`,
        );
        expect(downloadAnchor.click).toHaveBeenCalled();
      });
    });

    it(`shows the flash error when the export job status is 'failed'`, () => {
      setupMocksAndSpy(
        '/poll/until/complete',
        '/link/to/download',
        document.createElement('a'),
        'failed',
      );

      findCsvExportButton().vm.$emit('click');

      return axios.waitForAll().then(() => {
        expect(spy).not.toHaveBeenCalled();
        expect(createFlash).toHaveBeenCalledWith('There was an error while generating the report.');
      });
    });

    it('shows the flash error when backend fails to generate the export', () => {
      mock.onPost(vulnerabilitiesExportEndpoint).reply(statusCodes.NOT_FOUND, {});

      findCsvExportButton().vm.$emit('click');

      return axios.waitForAll().then(() => {
        expect(createFlash).toHaveBeenCalledWith('There was an error while generating the report.');
      });
    });

    it('displays the export icon when not loading and the loading icon when loading', () => {
      expect(findCsvExportButton().props('icon')).toBe('export');
      expect(findCsvExportButton().props('loading')).toBe(false);

      wrapper.setData({
        isPreparingCsvExport: true,
      });

      return wrapper.vm.$nextTick(() => {
        expect(findCsvExportButton().props('icon')).toBeFalsy();
        expect(findCsvExportButton().props('loading')).toBe(true);
      });
    });

    it('displays the popover by default', () => {
      expect(findPopover().attributes('show')).toBeTruthy();
    });

    it('closes the popover when the button is clicked', () => {
      const button = findPopoverButton();
      expect(button.text().trim()).toBe('Got it!');
      button.vm.$emit('click');
      return wrapper.vm.$nextTick(() => {
        expect(findPopover().attributes('show')).toBeFalsy();
      });
    });
  });

  describe('when user closed the popover before', () => {
    beforeEach(() => {
      localStorage.setItem(STORAGE_KEY, 'true');
      wrapper = createComponent();
    });

    it('does not display the popover anymore', () => {
      expect(findPopover().attributes('show')).toBeFalsy();
    });
  });
});
