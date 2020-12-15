import { shallowMount, mount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import waitForPromises from 'helpers/wait_for_promises';
import MetricsImage from 'ee/issue_show/components/incidents/metrics_image.vue';

const defaultProps = {
  id: 1,
  filePath: 'test_file_path',
  filename: 'test_file_name',
};

describe('Metrics upload item', () => {
  let wrapper;

  const mountComponent = (propsData = {}, mountMethod = mount) => {
    wrapper = mountMethod(MetricsImage, {
      propsData: {
        ...defaultProps,
        ...propsData,
      },
    });
  };

  afterEach(() => {
    if (wrapper) {
      wrapper.destroy();
      wrapper = null;
    }
  });

  const findImageLink = () => wrapper.find(GlLink);
  const findCollapseButton = () => wrapper.find('[data-testid="collapse-button"]');
  const findMetricImageBody = () => wrapper.find('[data-testid="metric-image-body"]');

  it('render the metrics image component', () => {
    mountComponent({}, shallowMount);

    expect(wrapper.element).toMatchSnapshot();
  });

  it('shows a link with the correct url', () => {
    const testUrl = 'test_url';
    mountComponent({ url: testUrl });

    expect(findImageLink().attributes('href')).toBe(testUrl);
    expect(findImageLink().text()).toBe(defaultProps.filename);
  });

  describe('expand and collapse', () => {
    beforeEach(() => {
      mountComponent();
    });

    it('the card is expanded by default', () => {
      expect(findMetricImageBody().isVisible()).toBe(true);
    });

    it('the card is collapsed when clicked', async () => {
      findCollapseButton().trigger('click');

      await waitForPromises();

      expect(findMetricImageBody().isVisible()).toBe(false);
    });
  });
});
