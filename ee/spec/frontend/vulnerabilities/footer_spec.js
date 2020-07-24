import { shallowMount } from '@vue/test-utils';
import VulnerabilityFooter from 'ee/vulnerabilities/components/footer.vue';
import HistoryEntry from 'ee/vulnerabilities/components/history_entry.vue';
import VulnerabilitiesEventBus from 'ee/vulnerabilities/components/vulnerabilities_event_bus';
import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';
import IssueNote from 'ee/vue_shared/security_reports/components/issue_note.vue';
import MergeRequestNote from 'ee/vue_shared/security_reports/components/merge_request_note.vue';
import MockAdapter from 'axios-mock-adapter';
import axios from '~/lib/utils/axios_utils';
import createFlash from '~/flash';
import initUserPopovers from '~/user_popovers';

const mockAxios = new MockAdapter(axios);
jest.mock('~/flash');
jest.mock('~/user_popovers');

describe('Vulnerability Footer', () => {
  let wrapper;

  const minimumProps = {
    discussionsUrl: `/discussions`,
    solutionInfo: {
      hasDownload: false,
      hasMr: false,
      hasRemediation: false,
      isStandaloneVulnerability: true,
      remediation: null,
      solution: undefined,
      vulnerabilityFeedbackHelpPath:
        '/help/user/application_security/index#interacting-with-the-vulnerabilities',
    },
    finding: {},
    notesUrl: '/notes',
    project: {
      full_path: '/root/security-reports',
      full_name: 'Administrator / Security Reports',
    },
  };

  const solutionInfoProp = {
    hasDownload: true,
    hasMr: false,
    isStandaloneVulnerability: true,
    remediation: {},
    solution: 'Upgrade to fixed version.\n',
    vulnerabilityFeedbackHelpPath:
      '/help/user/application_security/index#interacting-with-the-vulnerabilities',
  };

  const createWrapper = (props = minimumProps) => {
    wrapper = shallowMount(VulnerabilityFooter, {
      propsData: props,
    });
  };

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
    mockAxios.reset();
  });

  describe('vulnerabilities event bus listener', () => {
    it('calls the discussion url on vulnerabilities event bus emit of VULNERABILITY_STATE_CHANGE', () => {
      createWrapper();
      jest.spyOn(axios, 'get');
      VulnerabilitiesEventBus.$emit('VULNERABILITY_STATE_CHANGE');
      expect(axios.get).toHaveBeenCalledTimes(1);
    });
  });

  describe('solution card', () => {
    it('does show solution card when there is one', () => {
      createWrapper({ ...minimumProps, solutionInfo: solutionInfoProp });
      expect(wrapper.contains(SolutionCard)).toBe(true);
      expect(wrapper.find(SolutionCard).props()).toMatchObject(solutionInfoProp);
    });

    it('does not show solution card when there is not one', () => {
      createWrapper();
      expect(wrapper.contains(SolutionCard)).toBe(false);
    });
  });

  describe.each`
    type               | prop                      | component
    ${'issue'}         | ${'issueFeedback'}        | ${IssueNote}
    ${'merge request'} | ${'mergeRequestFeedback'} | ${MergeRequestNote}
  `('$type note', ({ prop, component }) => {
    // The object itself does not matter, we just want to make sure it's passed to the issue note.
    const feedback = {};

    it('shows issue note when an issue exists for the vulnerability', () => {
      createWrapper({ ...minimumProps, [prop]: feedback });
      expect(wrapper.contains(component)).toBe(true);
      expect(wrapper.find(component).props()).toMatchObject({
        feedback,
      });
    });

    it('does not show issue note when there is no issue for the vulnerability', () => {
      createWrapper();
      expect(wrapper.contains(component)).toBe(false);
    });
  });

  describe('state history', () => {
    const discussionUrl = '/discussions';

    const historyList = () => wrapper.find({ ref: 'historyList' });
    const historyEntries = () => wrapper.findAll(HistoryEntry);

    it('does not render the history list if there are no history items', () => {
      mockAxios.onGet(discussionUrl).replyOnce(200, []);
      createWrapper();
      expect(historyList().exists()).toBe(false);
    });

    it('renders the history list if there are history items', () => {
      // The shape of this object doesn't matter for this test, we just need to verify that it's passed to the history
      // entry.
      const historyItems = [{ id: 1, note: 'some note' }, { id: 2, note: 'another note' }];
      mockAxios.onGet(discussionUrl).replyOnce(200, historyItems, { date: Date.now() });
      createWrapper();

      return axios.waitForAll().then(() => {
        expect(historyList().exists()).toBe(true);
        expect(historyEntries()).toHaveLength(2);
        const entry1 = historyEntries().at(0);
        const entry2 = historyEntries().at(1);
        expect(entry1.props('discussion')).toEqual(historyItems[0]);
        expect(entry2.props('discussion')).toEqual(historyItems[1]);
      });
    });

    it('calls initUserPopovers when a new history item is retrieved', () => {
      const historyItems = [{ id: 1, note: 'some note' }];
      mockAxios.onGet(discussionUrl).replyOnce(200, historyItems, { date: Date.now() });

      expect(initUserPopovers).not.toHaveBeenCalled();
      createWrapper();

      return axios.waitForAll().then(() => {
        expect(initUserPopovers).toHaveBeenCalled();
      });
    });

    it('shows an error the history list could not be retrieved', () => {
      mockAxios.onGet(discussionUrl).replyOnce(500);
      createWrapper();

      return axios.waitForAll().then(() => {
        expect(createFlash).toHaveBeenCalledTimes(1);
      });
    });

    describe('new notes polling', () => {
      const getDiscussion = (entries, index) => entries.at(index).props('discussion');
      const createNotesRequest = (...notes) =>
        mockAxios
          .onGet(minimumProps.notesUrl)
          .replyOnce(200, { notes, last_fetched_at: Date.now() });

      beforeEach(() => {
        const historyItems = [
          { id: 1, notes: [{ id: 100, note: 'some note', discussion_id: 1 }] },
          { id: 2, notes: [{ id: 200, note: 'another note', discussion_id: 2 }] },
        ];
        mockAxios.onGet(discussionUrl).replyOnce(200, historyItems, { date: Date.now() });
        createWrapper();
      });

      it('updates an existing note if it already exists', () => {
        const note = { id: 100, note: 'updated note', discussion_id: 1 };
        createNotesRequest(note);

        return axios.waitForAll().then(() => {
          const entries = historyEntries();
          expect(entries).toHaveLength(2);
          const discussion = getDiscussion(entries, 0);
          expect(discussion.notes.length).toBe(1);
          expect(discussion.notes[0].note).toBe('updated note');
        });
      });

      it('adds a new note to an existing discussion if the note does not exist', () => {
        const note = { id: 101, note: 'new note', discussion_id: 1 };
        createNotesRequest(note);

        return axios.waitForAll().then(() => {
          const entries = historyEntries();
          expect(entries).toHaveLength(2);
          const discussion = getDiscussion(entries, 0);
          expect(discussion.notes.length).toBe(2);
          expect(discussion.notes[1].note).toBe('new note');
        });
      });

      it('creates a new discussion with a new note if the discussion does not exist', () => {
        const note = { id: 300, note: 'new note on a new discussion', discussion_id: 3 };
        createNotesRequest(note);

        return axios.waitForAll().then(() => {
          const entries = historyEntries();
          expect(entries).toHaveLength(3);
          const discussion = getDiscussion(entries, 2);
          expect(discussion.notes.length).toBe(1);
          expect(discussion.notes[0].note).toBe('new note on a new discussion');
        });
      });

      it('calls initUserPopovers when a new note is retrieved', () => {
        expect(initUserPopovers).not.toHaveBeenCalled();
        const note = { id: 300, note: 'new note on a new discussion', discussion_id: 3 };
        createNotesRequest(note);

        return axios.waitForAll().then(() => {
          expect(initUserPopovers).toHaveBeenCalled();
        });
      });

      it('shows an error if the notes poll fails', () => {
        mockAxios.onGet(minimumProps.notesUrl).replyOnce(500);

        return axios.waitForAll().then(() => {
          expect(historyEntries()).toHaveLength(2);
          expect(mockAxios.history.get).toHaveLength(2);
          expect(createFlash).toHaveBeenCalled();
        });
      });

      it('emits the VULNERABILITY_STATE_CHANGED event when the system note is new', async () => {
        const spy = jest.spyOn(VulnerabilitiesEventBus, '$emit');
        const note = { system: true, id: 1, discussion_id: 3 };
        createNotesRequest(note);
        await axios.waitForAll();

        expect(spy).toHaveBeenCalledTimes(1);
        expect(spy).toHaveBeenCalledWith('VULNERABILITY_STATE_CHANGED');
      });
    });
  });
});
