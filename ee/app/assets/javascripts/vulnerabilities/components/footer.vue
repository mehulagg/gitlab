<script>
import Visibility from 'visibilityjs';
import SolutionCard from 'ee/vue_shared/security_reports/components/solution_card.vue';
import MergeRequestNote from 'ee/vue_shared/security_reports/components/merge_request_note.vue';
import Api from 'ee/api';
import { VULNERABILITY_STATE_OBJECTS } from 'ee/vulnerabilities/constants';
import { GlIcon } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';
import Poll from '~/lib/utils/poll';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { s__, __ } from '~/locale';
import RelatedIssues from './related_issues.vue';
import HistoryEntry from './history_entry.vue';
import StatusDescription from './status_description.vue';
import initUserPopovers from '~/user_popovers';

export default {
  name: 'VulnerabilityFooter',
  components: {
    SolutionCard,
    MergeRequestNote,
    HistoryEntry,
    RelatedIssues,
    GlIcon,
    StatusDescription,
  },
  props: {
    vulnerability: {
      type: Object,
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
        .flatMap((x) => x.notes)
        .reduce((acc, note) => {
          acc[note.id] = note;
          return acc;
        }, {});
    },
    project() {
      return {
        url: this.vulnerability.project.fullPath,
        value: this.vulnerability.project.fullName,
      };
    },
    solutionInfo() {
      const { solution, hasMr, remediations, state } = this.vulnerability;

      const remediation = remediations?.[0];
      const hasDownload = Boolean(
        state !== VULNERABILITY_STATE_OBJECTS.resolved.state && remediation?.diff?.length && !hasMr,
      );

      return {
        solution,
        remediation,
        hasDownload,
        hasMr,
      };
    },
    hasSolution() {
      return Boolean(this.solutionInfo.solution || this.solutionInfo.remediation);
    },
    issueLinksEndpoint() {
      return Api.buildUrl(Api.vulnerabilityIssueLinksPath).replace(':id', this.vulnerability.id);
    },
    vulnerabilityDetectionData() {
      return {
        state: 'detected',
        pipeline: this.vulnerability.pipeline,
      };
    },
  },

  created() {
    this.fetchDiscussions();
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
        .get(this.vulnerability.discussionsUrl)
        .then(({ data, headers: { date } }) => {
          this.discussionsDictionary = data.reduce((acc, discussion) => {
            acc[discussion.id] = convertObjectPropsToCamelCase(discussion, { deep: true });
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
            axios.get(this.vulnerability.notesUrl, {
              headers: { 'X-Last-Fetched-At': this.lastFetchedAt },
            }),
        },
        method: 'fetchNotes',
        successCallback: ({ data: { notes, last_fetched_at: lastFetchedAt } }) => {
          this.updateNotes(convertObjectPropsToCamelCase(notes, { deep: true }));
          this.lastFetchedAt = lastFetchedAt;
        },
        errorCallback: () =>
          createFlash(__('Something went wrong while fetching latest comments.')),
      });
    },
    updateNotes(notes) {
      let isVulnerabilityStateChanged = false;

      notes.forEach((note) => {
        // If the note exists, update it.
        if (this.noteDictionary[note.id]) {
          const updatedDiscussion = { ...this.discussionsDictionary[note.discussionId] };
          updatedDiscussion.notes = updatedDiscussion.notes.map((curr) =>
            curr.id === note.id ? note : curr,
          );
          this.discussionsDictionary[note.discussionId] = updatedDiscussion;
        }
        // If the note doesn't exist, but the discussion does, add the note to the discussion.
        else if (this.discussionsDictionary[note.discussionId]) {
          const updatedDiscussion = { ...this.discussionsDictionary[note.discussionId] };
          updatedDiscussion.notes.push(note);
          this.discussionsDictionary[note.discussionId] = updatedDiscussion;
        }
        // If the discussion doesn't exist, create it.
        else {
          const newDiscussion = {
            id: note.discussionId,
            replyId: note.discussionId,
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
        this.$emit('vulnerability-state-change');
      }
    },
  },
};
</script>
<template>
  <div data-qa-selector="vulnerability_footer">
    <solution-card v-if="hasSolution" v-bind="solutionInfo" />

    <div v-if="vulnerability.mergeRequestFeedback" class="card gl-mt-5">
      <merge-request-note
        :feedback="vulnerability.mergeRequestFeedback"
        :project="project"
        class="card-body"
      />
    </div>

    <related-issues
      :endpoint="issueLinksEndpoint"
      :can-modify-related-issues="vulnerability.canModifyRelatedIssues"
      :project-path="project.url"
      :help-path="vulnerability.relatedIssuesHelpPath"
    />

    <div class="notes" data-testid="detection-note">
      <div class="system-note gl-display-flex gl-align-items-center gl-p-0! gl-mt-6!">
        <div class="timeline-icon gl-m-0!">
          <gl-icon name="search-dot" class="circle-icon-container" />
        </div>
        <status-description
          :vulnerability="vulnerabilityDetectionData"
          :is-state-bolded="true"
          class="gl-ml-5"
        />
      </div>
    </div>

    <hr />

    <ul v-if="discussions.length" ref="historyList" class="notes discussion-body">
      <history-entry
        v-for="discussion in discussions"
        :key="discussion.id"
        :discussion="discussion"
        :notes-url="vulnerability.notesUrl"
      />
    </ul>
  </div>
</template>
