import { useLocalStorageSpy } from 'helpers/local_storage_helper';
import * as types from '~/error_tracking/store/list/mutation_types';
import mutations from '~/error_tracking/store/list/mutations';

const ADD_RECENT_SEARCH = mutations[types.ADD_RECENT_SEARCH];
const CLEAR_RECENT_SEARCHES = mutations[types.CLEAR_RECENT_SEARCHES];
const LOAD_RECENT_SEARCHES = mutations[types.LOAD_RECENT_SEARCHES];
const REMOVE_IGNORED_RESOLVED_ERRORS = mutations[types.REMOVE_IGNORED_RESOLVED_ERRORS];
const SET_STATUS_FILTER = mutations[types.SET_STATUS_FILTER];

describe('Error tracking mutations', () => {
  describe('SET_ERRORS', () => {
    let state;

    beforeEach(() => {
      state = { errors: [] };
    });

    it('camelizes response', () => {
      const errors = [
        {
          title: 'the title',
          external_url: 'localhost:3456',
          count: 100,
          userCount: 10,
        },
      ];

      mutations[types.SET_ERRORS](state, errors);

      expect(state).toEqual({
        errors: [
          {
            title: 'the title',
            externalUrl: 'localhost:3456',
            count: 100,
            userCount: 10,
          },
        ],
      });
    });
  });

  describe('recent searches', () => {
    useLocalStorageSpy();
    let state;

    beforeEach(() => {
      state = {
        indexPath: '/project/errors.json',
        recentSearches: [],
      };
    });

    describe('ADD_RECENT_SEARCH', () => {
      it('adds search queries to recentSearches and localStorage', () => {
        ADD_RECENT_SEARCH(state, 'my issue');

        expect(state.recentSearches).toEqual(['my issue']);
        expect(localStorage.setItem).toHaveBeenCalledWith(
          'recent-searches/project/errors.json',
          '["my issue"]',
        );
      });

      it('does not add empty searches', () => {
        ADD_RECENT_SEARCH(state, '');

        expect(state.recentSearches).toEqual([]);
        expect(localStorage.setItem).not.toHaveBeenCalled();
      });

      it('adds new queries to start of the list', () => {
        state.recentSearches = ['previous', 'searches'];

        ADD_RECENT_SEARCH(state, 'new search');

        expect(state.recentSearches).toEqual(['new search', 'previous', 'searches']);
      });

      it('limits recentSearches to 5 items', () => {
        state.recentSearches = [1, 2, 3, 4, 5];

        ADD_RECENT_SEARCH(state, 'new search');

        expect(state.recentSearches).toEqual(['new search', 1, 2, 3, 4]);
      });

      it('does not add same search query twice', () => {
        state.recentSearches = ['already', 'searched'];

        ADD_RECENT_SEARCH(state, 'searched');

        expect(state.recentSearches).toEqual(['searched', 'already']);
      });
    });

    describe('CLEAR_RECENT_SEARCHES', () => {
      it('clears recentSearches and localStorage', () => {
        state.recentSearches = ['first', 'second'];

        CLEAR_RECENT_SEARCHES(state);

        expect(state.recentSearches).toEqual([]);
        expect(localStorage.removeItem).toHaveBeenCalledWith('recent-searches/project/errors.json');
      });
    });

    describe('LOAD_RECENT_SEARCHES', () => {
      it('loads recent searches from localStorage', () => {
        jest.spyOn(window.localStorage, 'getItem').mockReturnValue('["first", "second"]');

        LOAD_RECENT_SEARCHES(state);

        expect(state.recentSearches).toEqual(['first', 'second']);
        expect(localStorage.getItem).toHaveBeenCalledWith('recent-searches/project/errors.json');
      });
    });

    describe('REMOVE_IGNORED_RESOLVED_ERRORS', () => {
      it('removes ignored or resolved errors from list', () => {
        state.errors = [
          {
            id: 1,
            status: 'unresolved',
          },
          {
            id: 2,
            status: 'ignored',
          },
          {
            id: 3,
            status: 'unresolved',
          },
        ];
        const ignoredError = state.errors[2].id;

        REMOVE_IGNORED_RESOLVED_ERRORS(state, ignoredError);

        expect(state.errors).not.toContain(ignoredError);
      });
    });

    describe('SET_STATUS_FILTER', () => {
      it('sets the filter to ignored, resolved or unresolved', () => {
        state.statusFilter = 'unresolved';

        SET_STATUS_FILTER(state, 'ignored');

        expect(state.statusFilter).toBe('ignored');
      });
    });
  });
});
