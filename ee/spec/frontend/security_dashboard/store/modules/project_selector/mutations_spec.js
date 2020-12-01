import * as types from 'ee/security_dashboard/store/modules/project_selector/mutation_types';
import mutations from 'ee/security_dashboard/store/modules/project_selector/mutations';
import createState from 'ee/security_dashboard/store/modules/project_selector/state';

describe('EE projectsSelector mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('SET_PROJECT_ENDPOINTS', () => {
    it('sets "projectEndpoints.list" and "projectEndpoints.add"', () => {
      const payload = { list: 'list', add: 'add' };

      state.projectEndpoints = {};

      mutations[types.SET_PROJECT_ENDPOINTS](state, payload);

      expect(state.projectEndpoints.list).toBe(payload.list);
      expect(state.projectEndpoints.add).toBe(payload.add);
    });
  });

  describe('SET_SEARCH_QUERY', () => {
    it('sets "searchQuery" to be the given payload', () => {
      const payload = 'searchQuery';
      state.searchQuery = '';

      mutations[types.SET_SEARCH_QUERY](state, payload);

      expect(state.searchQuery).toBe(payload);
    });
  });

  describe('SELECT_PROJECT', () => {
    it('adds the given project to "selectedProjects"', () => {
      const payload = {};
      state.selectedProjects = [];

      mutations[types.SELECT_PROJECT](state, payload);

      expect(state.selectedProjects[0]).toBe(payload);
    });

    it('prevents projects from being added to "selectedProjects" twice', () => {
      const payload1 = { id: 1 };
      const payload2 = { id: 2 };

      mutations[types.SELECT_PROJECT](state, payload1);
      mutations[types.SELECT_PROJECT](state, payload1);

      expect(state.selectedProjects).toHaveLength(1);

      mutations[types.SELECT_PROJECT](state, payload2);

      expect(state.selectedProjects).toHaveLength(2);
    });
  });

  describe('DESELECT_PROJECT', () => {
    it('removes the project with the given id from "selectedProjects"', () => {
      state.selectedProjects = [{ id: 1 }, { id: 2 }];
      const payload = { id: 1 };

      mutations[types.DESELECT_PROJECT](state, payload);

      expect(state.selectedProjects).toHaveLength(1);
      expect(state.selectedProjects[0].id).toBe(2);
    });
  });

  describe('REQUEST_ADD_PROJECTS', () => {
    it('sets "isAddingProjects" to be true', () => {
      state.isAddingProjects = false;

      mutations[types.REQUEST_ADD_PROJECTS](state);

      expect(state.isAddingProjects).toBe(true);
    });
  });

  describe('RECEIVE_ADD_PROJECTS_SUCCESS', () => {
    it('sets "isAddingProjects" to be true', () => {
      state.isAddingProjects = true;

      mutations[types.RECEIVE_ADD_PROJECTS_SUCCESS](state);

      expect(state.isAddingProjects).toBe(false);
    });
  });

  describe('RECEIVE_ADD_PROJECTS_ERROR', () => {
    it('sets "isAddingProjects" to be true', () => {
      state.isAddingProjects = true;

      mutations[types.RECEIVE_ADD_PROJECTS_ERROR](state);

      expect(state.isAddingProjects).toBe(false);
    });
  });

  describe('REQUEST_REMOVE_PROJECT', () => {
    it('sets "isRemovingProjects" to be true', () => {
      state.isRemovingProject = false;

      mutations[types.REQUEST_REMOVE_PROJECT](state);

      expect(state.isRemovingProject).toBe(true);
    });
  });

  describe('RECEIVE_REMOVE_PROJECT_SUCCESS', () => {
    it('sets "isRemovingProjects" to be true', () => {
      state.isRemovingProject = true;

      mutations[types.RECEIVE_REMOVE_PROJECT_SUCCESS](state);

      expect(state.isRemovingProject).toBe(false);
    });
  });

  describe('RECEIVE_REMOVE_PROJECT_ERROR', () => {
    it('sets "isRemovingProjects" to be true', () => {
      state.isRemovingProject = true;

      mutations[types.RECEIVE_REMOVE_PROJECT_ERROR](state);

      expect(state.isRemovingProject).toBe(false);
    });
  });

  describe('REQUEST_PROJECTS', () => {
    it('sets "isLoadingProjects" to be true', () => {
      state.isLoadingProjects = false;

      mutations[types.REQUEST_PROJECTS](state);

      expect(state.isLoadingProjects).toBe(true);
    });
  });

  describe('RECEIVE_PROJECTS_SUCCESS', () => {
    it('sets "projects" to be the payload', () => {
      const payload = [];
      state.projects = [];

      mutations[types.RECEIVE_PROJECTS_SUCCESS](state, payload);

      expect(state.projects).toBe(payload);
    });

    it('sets "isLoadingProjects" to be false', () => {
      state.isLoadingProjects = true;

      mutations[types.RECEIVE_PROJECTS_SUCCESS](state, []);

      expect(state.isLoadingProjects).toBe(false);
    });
  });

  describe('RECEIVE_PROJECTS_ERROR', () => {
    it('sets "projects" to be an empty array', () => {
      state.projects = [];

      mutations[types.RECEIVE_PROJECTS_ERROR](state);

      expect(state.projects).toEqual([]);
    });

    it('sets "isLoadingProjects" to be false', () => {
      state.isLoadingProjects = true;

      mutations[types.RECEIVE_PROJECTS_ERROR](state);

      expect(state.isLoadingProjects).toBe(false);
    });
  });

  describe('CLEAR_SEARCH_RESULTS', () => {
    it('sets "projectSearchResults" to be an empty array', () => {
      state.projectSearchResults = [''];

      mutations[types.CLEAR_SEARCH_RESULTS](state);

      expect(state.projectSearchResults).toHaveLength(0);
    });

    it('sets "selectedProjects" to be an empty array', () => {
      state.selectedProjects = [''];

      mutations[types.CLEAR_SEARCH_RESULTS](state);

      expect(state.selectedProjects).toHaveLength(0);
    });
  });

  describe('REQUEST_SEARCH_RESULTS', () => {
    it('sets "messages.minimumQuery" to be false', () => {
      state.messages.minimumQuery = true;

      mutations[types.REQUEST_SEARCH_RESULTS](state);

      expect(state.messages.minimumQuery).toBe(false);
    });

    it('increments "searchCount" by one', () => {
      state.searchCount = 0;

      mutations[types.REQUEST_SEARCH_RESULTS](state);

      expect(state.searchCount).toBe(1);
    });
  });

  describe('RECEIVE_SEARCH_RESULTS_SUCCESS', () => {
    it('sets "projectSearchResults" to be the payload', () => {
      const payload = { data: [{ id: 1, name: 'test-project' }] };

      mutations[types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, payload);

      expect(state.projectSearchResults).toBe(payload.data);
    });

    it('sets "messages.noResults" to be false if the payload is not empty', () => {
      const payload = { data: [{ id: 1, name: 'test-project' }] };

      state.messages.noResults = true;

      mutations[types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, payload);

      expect(state.messages.noResults).toBe(false);
    });

    it('sets "messages.searchError" to be false', () => {
      const payload = { data: [{ id: 1, name: 'test-project' }] };

      state.messages.searchError = true;

      mutations[types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, payload);

      expect(state.messages.searchError).toBe(false);
    });

    it('sets "messages.minimumQuery" to be false', () => {
      const payload = { data: [{ id: 1, name: 'test-project' }] };

      state.messages.minimumQuery = true;

      mutations[types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, payload);

      expect(state.messages.minimumQuery).toBe(false);
    });

    it('decrements "searchCount" by one', () => {
      const payload = { data: [{ id: 1, name: 'test-project' }] };

      state.searchCount = 1;

      mutations[types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, payload);

      expect(state.searchCount).toBe(0);
    });

    it('does not decrement "searchCount" into negative', () => {
      const payload = { data: [{ id: 1, name: 'test-project' }] };

      state.searchCount = 0;

      mutations[types.RECEIVE_SEARCH_RESULTS_SUCCESS](state, payload);

      expect(state.searchCount).toBe(0);
    });
  });

  describe('RECEIVE_SEARCH_RESULTS_ERROR', () => {
    it('sets "projectSearchResult" to be empty', () => {
      state.projectSearchResults = [''];

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.projectSearchResults).toHaveLength(0);
    });

    it('sets "messages.noResults" to be false', () => {
      state.messages.noResults = true;

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.messages.noResults).toBe(false);
    });

    it('sets "messages.searchError" to be true', () => {
      state.messages.searchError = false;

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.messages.searchError).toBe(true);
    });

    it('sets "messages.minimumQuery" to be false', () => {
      state.messages.minimumQuery = true;

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.messages.minimumQuery).toBe(false);
    });

    it('decrements "searchCount" by one', () => {
      state.searchCount = 1;

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.searchCount).toBe(0);
    });

    it('does not decrement "searchCount" into negative', () => {
      state.searchCount = 0;

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.searchCount).toBe(0);
    });
  });

  describe('SET_MINIMUM_QUERY_MESSAGE', () => {
    it('sets "projectSearchResult" to be an empty array', () => {
      state.projectSearchResults = [''];

      mutations[types.SET_MINIMUM_QUERY_MESSAGE](state);

      expect(state.projectSearchResults).toHaveLength(0);
    });

    it('sets "pageInfo.total" to be 0', () => {
      state.pageInfo.total = 1;

      mutations[types.SET_MINIMUM_QUERY_MESSAGE](state);

      expect(state.pageInfo.total).toBe(0);
    });

    it('sets "messages.noResults" to be false', () => {
      state.messages.noResults = true;

      mutations[types.SET_MINIMUM_QUERY_MESSAGE](state);

      expect(state.messages.noResults).toBe(false);
    });

    it('sets "messages.searchError" to be false', () => {
      state.messages.searchError = true;

      mutations[types.SET_MINIMUM_QUERY_MESSAGE](state);

      expect(state.messages.searchError).toBe(false);
    });

    it('sets "messages.minimumQuery" to true', () => {
      state.messages.minimumQuery = false;

      mutations[types.SET_MINIMUM_QUERY_MESSAGE](state);

      expect(state.messages.minimumQuery).toBe(true);
    });

    it('does not decrement "searchCount" into negative', () => {
      state.searchCount = 0;

      mutations[types.RECEIVE_SEARCH_RESULTS_ERROR](state);

      expect(state.searchCount).toBe(0);
    });
  });

  describe('RECEIVE_NEXT_PAGE_SUCCESS', () => {
    it('appends the data from the payload to "projectsSearchResults"', () => {
      state.projectSearchResults = ['foo'];

      const payload = { data: ['bar'] };

      mutations[types.RECEIVE_NEXT_PAGE_SUCCESS](state, payload);

      expect(state.projectSearchResults).toEqual(['foo', 'bar']);
    });

    it('sets "pageInfo" to be the given payload', () => {
      const payload = { pageInfo: { foo: 'foo', bar: 'bar' } };

      mutations[types.RECEIVE_NEXT_PAGE_SUCCESS](state, payload);

      expect(state.pageInfo).toEqual(payload.pageInfo);
    });
  });
});
