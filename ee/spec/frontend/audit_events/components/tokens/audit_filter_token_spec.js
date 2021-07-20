import { GlLoadingIcon } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import AuditFilterToken from 'ee/audit_events/components/tokens/shared/audit_filter_token.vue';
import createFlash from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';

jest.mock('~/flash');

describe('AuditFilterToken', () => {
  let wrapper;
  const item = { name: 'An item name' };
  const suggestions = [
    {
      id: 1,
      name: 'A suggestion name',
      avatar_url: 'www',
      full_name: 'Full name',
    },
  ];

  const findFilteredSearchToken = () => wrapper.find('#filtered-search-token');
  const findLoadingIcon = (type) => wrapper.find(type).find(GlLoadingIcon);

  const tokenMethods = {
    fetchItem: jest.fn().mockResolvedValue(item),
    fetchSuggestions: jest.fn().mockResolvedValue(suggestions),
    getItemName: jest.fn(),
  };

  const initComponent = (props = {}) => {
    wrapper = shallowMount(AuditFilterToken, {
      propsData: {
        value: {},
        config: {
          type: 'foo',
        },
        active: false,
        ...tokenMethods,
        ...props,
      },
      stubs: {
        GlFilteredSearchToken: {
          template: `<div id="filtered-search-token">
            <div class="view"><slot name="view"></slot></div>
            <div class="suggestions"><slot name="suggestions"></slot></div>
          </div>`,
        },
      },
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe('when initialized', () => {
    it('passes the config correctly', () => {
      const config = {
        icon: 'user',
        type: 'user',
        title: 'User',
        unique: true,
      };
      initComponent({ config });

      expect(findFilteredSearchToken().props('config')).toEqual(config);
    });

    it('passes the value correctly', () => {
      const value = { data: 1 };
      initComponent({ value });

      expect(findFilteredSearchToken().props('value')).toEqual(value);
    });

    describe('with a value', () => {
      const value = { data: 1 };
      beforeEach(() => {
        initComponent({ value });
      });

      it('matches the snapshot', () => {
        expect(wrapper.element).toMatchSnapshot();
      });

      it('fetches an item to display', () => {
        expect(tokenMethods.fetchItem).toHaveBeenCalledWith(value.data);
      });
    });

    describe('without a value', () => {
      beforeEach(() => {
        initComponent();
      });

      it('matches the snapshot', () => {
        expect(wrapper.element).toMatchSnapshot();
      });

      it('fetches suggestions to display', () => {
        expect(tokenMethods.fetchSuggestions).toHaveBeenCalled();
      });
    });
  });

  describe('when fetching suggestions', () => {
    let resolveSuggestions;
    let rejectSuggestions;
    const fetchSuggestions = () =>
      new Promise((resolve, reject) => {
        resolveSuggestions = resolve;
        rejectSuggestions = reject;
      });

    beforeEach(() => {
      const value = { data: '' };
      initComponent({ value, fetchSuggestions });
    });

    it('shows the suggestions loading icon', () => {
      expect(findLoadingIcon('.suggestions').exists()).toBe(true);
      expect(findLoadingIcon('.view').exists()).toBe(false);
    });

    describe('and the fetch succeeds', () => {
      beforeEach(() => {
        resolveSuggestions(suggestions);
      });

      it('does not show the suggestions loading icon', () => {
        expect(findLoadingIcon('.suggestions').exists()).toBe(false);
      });
    });

    describe('and the fetch fails', () => {
      beforeEach(() => {
        rejectSuggestions({ response: { status: httpStatusCodes.NOT_FOUND } });
      });

      it('shows a flash error message', () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to find foo. Please search for another foo.',
        });
      });
    });

    describe('and the fetch fails with a multi-word type', () => {
      beforeEach(() => {
        initComponent({ config: { type: 'foo_bar' }, fetchSuggestions });
        rejectSuggestions({ response: { status: httpStatusCodes.NOT_FOUND } });
      });

      it('shows a flash error message', () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to find foo bar. Please search for another foo bar.',
        });
      });
    });
  });

  describe('when fetching the view item', () => {
    let resolveItem;
    let rejectItem;
    beforeEach(() => {
      const value = { data: 1 };
      const fetchItem = () =>
        new Promise((resolve, reject) => {
          resolveItem = resolve;
          rejectItem = reject;
        });
      initComponent({ value, fetchItem });
    });

    it('shows the view loading icon', () => {
      expect(findLoadingIcon('.view').exists()).toBe(true);
      expect(findLoadingIcon('.suggestions').exists()).toBe(false);
    });

    describe('and the fetch succeeds', () => {
      beforeEach(() => {
        resolveItem(item);
      });

      it('does not show the view loading icon', () => {
        expect(findLoadingIcon('.view').exists()).toBe(false);
      });
    });

    describe('and the fetch fails', () => {
      beforeEach(() => {
        rejectItem({ response: { status: httpStatusCodes.NOT_FOUND } });
      });

      it('shows a flash error message', () => {
        expect(createFlash).toHaveBeenCalledWith({
          message: 'Failed to find foo. Please search for another foo.',
        });
      });
    });
  });

  describe('when no suggestion could be found', () => {
    beforeEach(() => {
      const value = { data: '' };
      const fetchSuggestions = jest.fn().mockResolvedValue([]);
      initComponent({ value, fetchSuggestions });
    });

    it('renders an empty message', () => {
      expect(wrapper.text()).toBe('No matching foo found.');
    });
  });

  describe('when a view item could not be found', () => {
    beforeEach(() => {
      const value = { data: 1 };
      const fetchItem = jest.fn().mockResolvedValue({});
      initComponent({ value, fetchItem });
    });

    it('renders an empty message', () => {
      expect(wrapper.text()).toBe('No matching foo found.');
    });
  });
});
