<script>
import Visibility from 'visibilityjs';
import IssueNote from 'ee/vue_shared/security_reports/components/issue_note.vue';
import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';
import MergeRequestNote from 'ee/vue_shared/security_reports/components/merge_request_note.vue';
import Api from 'ee/api';
import axios from '~/lib/utils/axios_utils';
import Poll from '~/lib/utils/poll';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { s__, __ } from '~/locale';
import RelatedIssues from './related_issues.vue';
import HistoryEntry from './history_entry.vue';
import VulnerabilitiesEventBus from './vulnerabilities_event_bus';
import initUserPopovers from '~/user_popovers';

export default {
  name: 'VulnerabilityFooter',
  components: { IssueNote, SolutionCard, MergeRequestNote, HistoryEntry, RelatedIssues },
  props: {
    discussionsUrl: {
      type: String,
      required: true,
    },
    notesUrl: {
      type: String,
      required: true,
    },
    project: {
      type: Object,
      required: true,
    },
    solutionInfo: {
      type: Object,
      required: true,
    },
    issueFeedback: {
      type: Object,
      required: false,
      default: () => null,
    },
    mergeRequestFeedback: {
      type: Object,
      required: false,
      default: () => null,
    },
    vulnerabilityId: {
      type: Number,
      required: true,
    },
    canModifyRelatedIssues: {
      type: Boolean,
      required: true,
    },
    relatedIssuesHelpPath: {
      type: String,
      required: true,
    },
  },

  data: () => ({
    discussionsDictionary: {},
    lastFetchedAt: null,
  }),

  computed: {
    discussions() {
      return Object.values(this.discussionsDictionary);
    },
    noteDictionary() {
      return this.discussions
        .flatMap(x => x.notes)
        .reduce((acc, note) => {
          acc[note.id] = note;
          return acc;
        }, {});
    },
    hasSolution() {
      return Boolean(this.solutionInfo.solution || this.solutionInfo.remediation);
    },
    issueLinksEndpoint() {
      return Api.buildUrl(Api.vulnerabilityIssueLinksPath).replace(':id', this.vulnerabilityId);
    },
  },

  created() {
    this.fetchDiscussions();

    VulnerabilitiesEventBus.$on('VULNERABILITY_STATE_CHANGE', this.fetchDiscussions);
  },

  updated() {
    this.$nextTick(() => {
      initUserPopovers(this.$el.querySelectorAll('.js-user-link'));
    });
  },

  beforeDestroy() {
    if (this.poll) this.poll.stop();
  },

  methods: {
    dateToSeconds(date) {
      return Date.parse(date) / 1000;
    },
    fetchDiscussions() {
      axios
        .get(this.discussionsUrl)
        .then(({ data, headers: { date } }) => {
          this.discussionsDictionary = data.reduce((acc, discussion) => {
            acc[discussion.id] = discussion;
            return acc;
          }, {});

          this.lastFetchedAt = this.dateToSeconds(date);

          if (!this.poll) this.createNotesPoll();

          if (!Visibility.hidden()) {
            // delays the initial request by 6 seconds
            this.poll.makeDelayedRequest(6 * 1000);
          }

          Visibility.change(() => {
            if (Visibility.hidden()) {
              this.poll.stop();
            } else {
              this.poll.restart();
            }
          });
        })
        .catch(() => {
          createFlash(
            s__(
              'VulnerabilityManagement|Something went wrong while trying to retrieve the vulnerability history. Please try again later.',
            ),
          );
        });
    },
    createNotesPoll() {
      this.poll = new Poll({
        resource: {
          fetchNotes: () =>
            axios.get(this.notesUrl, { headers: { 'X-Last-Fetched-At': this.lastFetchedAt } }),
        },
        method: 'fetchNotes',
        successCallback: ({ data: { notes, last_fetched_at: lastFetchedAt } }) => {
          this.updateNotes(notes);
          this.lastFetchedAt = lastFetchedAt;
        },
        errorCallback: () =>
          createFlash(__('Something went wrong while fetching latest comments.')),
      });
    },
    updateNotes(notes) {
      let isVulnerabilityStateChanged = false;

      notes.forEach(note => {
        // If the note exists, update it.
        if (this.noteDictionary[note.id]) {
          const updatedDiscussion = { ...this.discussionsDictionary[note.discussion_id] };
          updatedDiscussion.notes = updatedDiscussion.notes.map(curr =>
            curr.id === note.id ? note : curr,
          );
          this.discussionsDictionary[note.discussion_id] = updatedDiscussion;
        }
        // If the note doesn't exist, but the discussion does, add the note to the discussion.
        else if (this.discussionsDictionary[note.discussion_id]) {
          const updatedDiscussion = { ...this.discussionsDictionary[note.discussion_id] };
          updatedDiscussion.notes.push(note);
          this.discussionsDictionary[note.discussion_id] = updatedDiscussion;
        }
        // If the discussion doesn't exist, create it.
        else {
          const newDiscussion = {
            id: note.discussion_id,
            reply_id: note.discussion_id,
            notes: [note],
          };
          this.$set(this.discussionsDictionary, newDiscussion.id, newDiscussion);

          // If the vulnerability status has changed, the note will be a system note.
          if (note.system === true) {
            isVulnerabilityStateChanged = true;
          }
        }
      });

      // Emit an event that tells the header to refresh the vulnerability.
      if (isVulnerabilityStateChanged) {
        VulnerabilitiesEventBus.$emit('VULNERABILITY_STATE_CHANGED');
      }
    },
  },

  emits: [],
};
</script>
<template>
  <div data-qa-selector="vulnerability_footer">
    <solution-card v-if="hasSolution" v-bind="solutionInfo" />

    <div v-if="issueFeedback || mergeRequestFeedback" class="card gl-mt-5">
      <issue-note
        v-if="issueFeedback"
        :feedback="issueFeedback"
        :project="project"
        class="card-body"
      />
      <merge-request-note
        v-if="mergeRequestFeedback"
        :feedback="mergeRequestFeedback"
        :project="project"
        class="card-body"
      />
    </div>

    <related-issues
      :endpoint="issueLinksEndpoint"
      :can-modify-related-issues="canModifyRelatedIssues"
      :project-path="project.url"
      :help-path="relatedIssuesHelpPath"
    />

    <hr />

    <ul v-if="discussions.length" ref="historyList" class="notes discussion-body">
      <history-entry
        v-for="discussion in discussions"
        :key="discussion.id"
        :discussion="discussion"
        :notes-url="notesUrl"
      />
    </ul>
  </div>
</template>
