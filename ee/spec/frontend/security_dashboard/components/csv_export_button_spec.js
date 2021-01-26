import { GlLoadingIcon, GlIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import MockAdapter from 'axios-mock-adapter';
import CsvExportButton, {
  STORAGE_KEY,
} from 'ee/security_dashboard/components/csv_export_button.vue';
import { useFakeDate } from 'helpers/fake_date';
import { TEST_HOST } from 'helpers/test_constants';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { formatDate } from '~/lib/utils/datetime_utility';
import downloader from '~/lib/utils/downloader';
import statusCodes from '~/lib/utils/http_status';

jest.mock('~/flash');
jest.mock('~/lib/utils/downloader');
useFakeDate();

const mockReportDate = formatDate(new Date(), 'isoDateTime');
const vulnerabilitiesExportEndpoint = `${TEST_HOST}/vulnerability_findings.csv`;

describe('Csv Button Export', () => {
  let mock;
  let wrapper;

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

  const mockCsvExportRequest = (download, status = 'finished') => {
    mock
      .onPost(vulnerabilitiesExportEndpoint)
      .reply(statusCodes.ACCEPTED, { _links: { self: 'status/url' } });

    mock.onGet('status/url').reply(statusCodes.OK, { _links: { download }, status });
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

    it('will start the download when clicked', async () => {
      const url = 'download/url';
      mockCsvExportRequest(url);

      findCsvExportButton().vm.$emit('click');
      await axios.waitForAll();

      expect(mock.history.post).toHaveLength(1); // POST is the create report endpoint.
      expect(mock.history.get).toHaveLength(1); // GET is the poll endpoint.
      expect(downloader).toHaveBeenCalledTimes(1);
      expect(downloader).toHaveBeenCalledWith({
        fileName: `csv-export-${mockReportDate}.csv`,
        url,
      });
    });

    it('shows the flash error when the export job status is failed', async () => {
      mockCsvExportRequest('', 'failed');

      findCsvExportButton().vm.$emit('click');
      await axios.waitForAll();

      expect(downloader).not.toHaveBeenCalled();
      expect(createFlash).toHaveBeenCalledWith('There was an error while generating the report.');
    });

    it('shows the flash error when backend fails to generate the export', async () => {
      mock.onPost(vulnerabilitiesExportEndpoint).reply(statusCodes.NOT_FOUND, {});

      findCsvExportButton().vm.$emit('click');
      await axios.waitForAll();

      expect(createFlash).toHaveBeenCalledWith('There was an error while generating the report.');
    });

    it('displays the export icon when not loading and the loading icon when loading', async () => {
      expect(findCsvExportButton().props()).toMatchObject({
        icon: 'export',
        loading: false,
      });

      wrapper.setData({ isPreparingCsvExport: true });
      await wrapper.vm.$nextTick();

      expect(findCsvExportButton().props()).toMatchObject({
        icon: '',
        loading: true,
      });
    });

    it('displays the popover by default', () => {
      expect(findPopover().attributes('show')).toBeTruthy();
    });

    it('closes the popover when the button is clicked', async () => {
      const button = findPopoverButton();
      expect(button.text().trim()).toBe('Got it!');
      button.vm.$emit('click');
      await wrapper.vm.$nextTick();

      expect(findPopover().attributes('show')).toBeUndefined();
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
