import axios from 'axios';
import MockAdapter from 'axios-mock-adapter';
import { initialSortBy, initialFilterValue } from '~/issues_list/filtered_search_init_helper';
import { setUrl, TEST_LOCATION } from './helpers';

describe('filtered search init helper', () => {
  let oldLocation;
  let mockAxios;

  beforeEach(() => {
    mockAxios = new MockAdapter(axios);

    oldLocation = window.location;
    Object.defineProperty(window, 'location', {
      writable: true,
      value: { href: '', search: '' },
    });
    window.location.href = TEST_LOCATION;
  });

  afterEach(() => {
    mockAxios.restore();
    window.location = oldLocation;
  });

  describe('initialSortBy', () => {
    const query = '?sort=updated_asc';

    it('sets default value', () => {
      expect(initialSortBy('initialSortBy')).toBe('created_desc');
    });

    it('sets value according to query', () => {
      setUrl(query);

      expect(initialSortBy('initialSortBy')).toBe('updated_asc');
    });
  });

  describe('initialFilterValue', () => {
    it('does not set value when no query', () => {
      expect(initialFilterValue()).toEqual([]);
    });

    it('sets value according to query', () => {
      const query = '?search=free+text';

      setUrl(query);

      expect(initialFilterValue()).toEqual(['free text']);
    });
  });
});
