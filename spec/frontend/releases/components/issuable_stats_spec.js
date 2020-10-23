import { mount } from '@vue/test-utils';
import { trimText } from 'helpers/text_helper';
import IssuableStats from '~/releases/components/issuable_stats.vue';

describe('~/releases/components/issuable_stats.vue', () => {
  let wrapper;
  let defaultProps;

  const createComponent = propUpdates => {
    wrapper = mount(IssuableStats, {
      propsData: {
        ...defaultProps,
        ...propUpdates,
      },
    });
  };

  beforeEach(() => {
    defaultProps = {
      label: 'Items',
      total: 10,
      closed: 2,
      openPath: 'path/to/open/items',
      closedPath: 'path/to/closed/items',
    };
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('snapshot', () => {
    beforeEach(() => {
      createComponent();
    });

    it('matches snapshot', () => {
      expect(wrapper).toMatchSnapshot();
    });
  });

  describe('when only total and closed counts are provided', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders a label with the total count; also, the opened count and the closed count', () => {
      expect(trimText(wrapper.text())).toMatchInterpolatedText('Items 10 Open: 8 • Closed: 2');
    });
  });

  describe('when only total, merged, and closed counts are provided', () => {
    beforeEach(() => {
      createComponent({ merged: 7 });
    });

    it('renders a label with the total count; also, the opened count, the merged count, and the closed count', () => {
      expect(wrapper.text()).toMatchInterpolatedText('Items 10 Open: 1 • Merged: 7 • Closed: 2');
    });
  });
});
