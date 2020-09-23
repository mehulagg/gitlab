import { shallowMount } from '@vue/test-utils';
import Component from 'ee/vue_shared/security_reports/components/dast_modal.vue';
import { GlModal } from '@gitlab/ui';

describe('DAST Modal', () => {
  let wrapper;

  const defaultProps = {
    scannedUrls: [{ requestMethod: 'POST', url: 'https://gitlab.com' }],
    scannedResourcesCount: 1,
    downloadLink: 'https://gitlab.com',
  };

  const findDownloadButton = () => wrapper.find('[data-testid="download-button"]');

  const createWrapper = propsData => {
    wrapper = shallowMount(Component, {
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
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('has the download button with required attrs', () => {
    expect(findDownloadButton().exists()).toBe(true);
    expect(findDownloadButton().attributes('href')).toBe(defaultProps.downloadLink);
    expect(findDownloadButton().attributes('download')).toBeDefined();
  });

  it('should contain the dynamic title', () => {
    createWrapper({ scannedResourcesCount: 20 });
    expect(wrapper.attributes('title')).toBe('20 Scanned URLs');
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
