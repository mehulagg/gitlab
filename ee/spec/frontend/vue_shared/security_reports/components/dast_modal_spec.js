import { shallowMount } from '@vue/test-utils';
import Component from 'ee/vue_shared/security_reports/components/dast_modal.vue';
import { GlModal } from '@gitlab/ui';
import MockAdapter from 'axios-mock-adapter';
import waitForPromises from 'helpers/wait_for_promises';
import httpStatus from '~/lib/utils/http_status';
import axios from '~/lib/utils/axios_utils';
import download from '~/lib/utils/downloader';

jest.mock('~/lib/utils/downloader');

describe('DAST Modal', () => {
  let wrapper;
  let mock;

  const defaultProps = {
    scannedUrls: [{ requestMethod: 'POST', url: 'https://gitlab.com' }],
    scannedResourcesCount: 1,
    downloadLink: 'https://gitlab.com',
  };

  const findDownloadButton = () => wrapper.find('[data-testid="download-button"]');
  const findModal = () => wrapper.find('[data-testid="dastModal"]');

  const createWrapper = propsData => {
    wrapper = shallowMount(Component, {
      provide: {
        glFeatures: { dastModalLoadingIndicator: true },
      },
      propsData: {
        ...defaultProps,
        ...propsData,
      },
      stubs: {
        GlModal,
      },
    });
  };
  beforeEach(() => {
    createWrapper();
    mock = new MockAdapter(axios);
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mock.restore();
  });

  it('has the download button with required attrs', () => {
    expect(findDownloadButton().exists()).toBe(true);
    expect(findDownloadButton().text()).toBe('Download as CSV');
  });

  it('should make request to downloadLink on click', async () => {
    const file = 'randomFileString';
    mock.onGet(defaultProps.downloadLink).replyOnce(httpStatus.OK, file);

    findDownloadButton().vm.$emit('click', {
      preventDefault: jest.fn(),
      defaultPrevented: true,
    });

    await waitForPromises();
    expect(download).toHaveBeenCalledWith({
      fileData: 'W29iamVjdCBPYmplY3Rd',
      fileName: 'scanned_resources',
      fileType: 'text/csv',
    });
  });

  it('should contain the dynamic title', () => {
    createWrapper({ scannedResourcesCount: 20 });
    expect(findModal().attributes('title')).toBe('20 Scanned URLs');
  });

  it('should not show download button when link is not present', () => {
    createWrapper({ downloadLink: '' });
    expect(findDownloadButton().exists()).toBe(false);
  });

  it('scanned urls should be limited to 15', () => {
    createWrapper({
      scannedUrls: Array(20).fill(defaultProps.scannedUrls[0]),
    });
    expect(wrapper.findAll('[data-testid="dast-scanned-url"]')).toHaveLength(15);
  });
});
