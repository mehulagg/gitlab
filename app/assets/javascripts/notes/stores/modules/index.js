import * as actions from '../actions';
import * as getters from '../getters';
import mutations from '../mutations';

export default {
  state: {
    discussions: [],
    targetNoteHash: null,
    lastFetchedAt: null,

    // View layer
    isToggleStateButtonLoading: false,
    isNotesFetched: false,

    // holds endpoints and permissions provided through haml
    notesData: {
      markdownDocsPath: '',
    },
    userData: {},
    noteableData: {
      current_user: {},
    },
  },
  actions,
  getters,
  mutations,
};
