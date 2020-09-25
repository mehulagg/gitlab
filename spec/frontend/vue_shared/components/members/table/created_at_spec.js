import { mount, createWrapper } from '@vue/test-utils';
import { getByText as getByTextHelper } from '@testing-library/dom';
import { useFakeDate } from 'helpers/fake_date';
import * as timeago from 'timeago.js';
import CreatedAt from '~/vue_shared/components/members/table/created_at.vue';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';

describe('CreatedAt', () => {
  // March 15th, 2020
  useFakeDate(2020, 2, 15);

  const date = '2020-03-01T00:00:00.000';
  const dateTimeAgo = '2 weeks ago';

  timeago.format = jest.fn(() => dateTimeAgo);

  let wrapper;

  const createComponent = propsData => {
    wrapper = mount(CreatedAt, {
      propsData: {
        date,
        ...propsData,
      },
    });
  };

  const getByText = (text, options) =>
    createWrapper(getByTextHelper(wrapper.element, text, options));

  afterEach(() => {
    wrapper.destroy();
  });

  describe('created at text', () => {
    let createdAtText;

    beforeEach(() => {
      createComponent();

      createdAtText = getByText(dateTimeAgo);
    });

    it('displays value returned by `timeago.js`', () => {
      createComponent();

      expect(timeago.format).toHaveBeenCalledWith(date);
      expect(createdAtText.exists()).toBe(true);
    });

    it('uses `TimeAgoTooltip` component', () => {
      expect(wrapper.find(TimeAgoTooltip).exists()).toBe(true);
    });
  });

  describe('when `createdBy` prop is provided', () => {
    it('displays a link to the user that created the member', () => {
      createComponent({
        createdBy: {
          name: 'Administrator',
          webUrl: 'https://gitlab.com/root',
        },
      });

      const link = getByText('Administrator');

      expect(link.exists()).toBe(true);
      expect(link.attributes('href')).toBe('https://gitlab.com/root');
    });
  });
});
