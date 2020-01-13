<script>
import { ApolloMutation } from 'vue-apollo';
import Mousetrap from 'mousetrap';
import { GlLoadingIcon, GlAlert } from '@gitlab/ui';
import createFlash from '~/flash';
import allVersionsMixin from '../../mixins/all_versions';
import Toolbar from '../../components/toolbar/index.vue';
import DesignDiscussion from '../../components/design_notes/design_discussion.vue';
import DesignReplyForm from '../../components/design_notes/design_reply_form.vue';
import DesignDestroyer from '../../components/design_destroyer.vue';
import DesignScaler from '../../components/design_scaler.vue';
import Participants from '~/sidebar/components/participants/participants.vue';
import DesignPresentation from '../../components/design_presentation.vue';
import getDesignQuery from '../../graphql/queries/getDesign.query.graphql';
import appDataQuery from '../../graphql/queries/appData.query.graphql';
import createImageDiffNoteMutation from '../../graphql/mutations/createImageDiffNote.mutation.graphql';
import {
  extractDiscussions,
  extractDesign,
  extractParticipants,
} from '../../utils/design_management_utils';
import { updateStoreAfterAddImageDiffNote } from '../../utils/cache_update';
import {
  ADD_DISCUSSION_COMMENT_ERROR,
  DESIGN_NOT_FOUND_ERROR,
  DESIGN_NOT_EXIST_ERROR,
  designDeletionError,
} from '../../utils/error_messages';

export default {
  components: {
    ApolloMutation,
    DesignPresentation,
    DesignDiscussion,
    DesignScaler,
    DesignDestroyer,
    Toolbar,
    DesignReplyForm,
    GlLoadingIcon,
    GlAlert,
    Participants,
  },
  mixins: [allVersionsMixin],
  props: {
    id: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      design: {},
      comment: '',
      annotationCoordinates: null,
      projectPath: '',
      errorMessage: '',
      issueIid: '',
      scale: 1,
    };
  },
  apollo: {
    appData: {
      query: appDataQuery,
      manual: true,
      result({ data: { projectPath, issueIid } }) {
        this.projectPath = projectPath;
        this.issueIid = issueIid;
      },
    },
    design: {
      query: getDesignQuery,
      fetchPolicy: 'network-only',
      variables() {
        return this.designVariables;
      },
      update: data => extractDesign(data),
      result({ data }) {
        if (!data) {
          this.onQueryError(DESIGN_NOT_FOUND_ERROR);
        }
        if (this.$route.query.version && !this.hasValidVersion) {
          this.onQueryError(DESIGN_NOT_EXIST_ERROR);
        }
      },
      error() {
        this.onQueryError(DESIGN_NOT_FOUND_ERROR);
      },
    },
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.design.loading;
    },
    discussions() {
      return extractDiscussions(this.design.discussions);
    },
    discussionParticipants() {
      return extractParticipants(this.design.issue.participants);
    },
    markdownPreviewPath() {
      return `/${this.projectPath}/preview_markdown?target_type=Issue`;
    },
    isSubmitButtonDisabled() {
      return this.comment.trim().length === 0;
    },
    renderDiscussions() {
      return this.discussions.length || this.annotationCoordinates;
    },
    designVariables() {
      return {
        fullPath: this.projectPath,
        iid: this.issueIid,
        filenames: [this.$route.params.id],
        atVersion: this.designsVersion,
      };
    },
    mutationPayload() {
      const { x, y, width, height } = this.annotationCoordinates;
      return {
        noteableId: this.design.id,
        body: this.comment,
        position: {
          headSha: this.design.diffRefs.headSha,
          baseSha: this.design.diffRefs.baseSha,
          startSha: this.design.diffRefs.startSha,
          x,
          y,
          width,
          height,
          paths: {
            newPath: this.design.fullPath,
          },
        },
      };
    },
    issue() {
      return {
        ...this.design.issue,
        webPath: this.design.issue.webPath.substr(1),
      };
    },
    isAnnotating() {
      return Boolean(this.annotationCoordinates);
    },
  },
  mounted() {
    Mousetrap.bind('esc', this.closeDesign);
  },
  beforeDestroy() {
    Mousetrap.unbind('esc', this.closeDesign);
  },
  methods: {
    addImageDiffNoteToStore(
      store,
      {
        data: { createImageDiffNote },
      },
    ) {
      updateStoreAfterAddImageDiffNote(
        store,
        createImageDiffNote,
        getDesignQuery,
        this.designVariables,
      );
    },
    onQueryError(message) {
      // because we redirect user to /designs (the issue page),
      // we want to create these flashes on the issue page
      createFlash(message);
      this.$router.push({ name: 'designs' });
    },
    onDiffNoteError(e) {
      this.errorMessage = ADD_DISCUSSION_COMMENT_ERROR;
      throw e;
    },
    onDesignDeleteError(e) {
      this.errorMessage = designDeletionError({ singular: true });
      throw e;
    },
    openCommentForm(annotationCoordinates) {
      this.annotationCoordinates = annotationCoordinates;
    },
    closeCommentForm() {
      this.comment = '';
      this.annotationCoordinates = null;
    },
    closeDesign() {
      this.$router.push({
        name: 'designs',
        query: this.$route.query,
      });
    },
  },
  beforeRouteUpdate(to, from, next) {
    this.closeCommentForm();
    next();
  },
  createImageDiffNoteMutation,
};
</script>

<template>
  <div
    class="design-detail fixed-top w-100 position-bottom-0 d-flex justify-content-center flex-column flex-lg-row"
  >
    <gl-loading-icon v-if="isLoading" size="xl" class="align-self-center" />
    <template v-else>
      <div class="d-flex overflow-hidden flex-grow-1 flex-column position-relative">
        <design-destroyer
          :filenames="[design.filename]"
          :project-path="projectPath"
          :iid="issueIid"
          @done="$router.push({ name: 'designs' })"
          @error="onDesignDeleteError"
        >
          <template v-slot="{ mutate, loading, error }">
            <toolbar
              :id="id"
              :is-deleting="loading"
              :is-latest-version="isLatestVersion"
              v-bind="design"
              @delete="mutate()"
            />
          </template>
        </design-destroyer>

        <div v-if="errorMessage" class="p-3">
          <gl-alert variant="danger" @dismiss="errorMessage = null">
            {{ errorMessage }}
          </gl-alert>
        </div>
        <design-presentation
          :image="design.image"
          :image-name="design.filename"
          :discussions="discussions"
          :is-annotating="isAnnotating"
          :scale="scale"
          @openCommentForm="openCommentForm"
        />
        <div class="design-scaler-wrapper position-absolute w-100 pb-3 d-flex-center">
          <design-scaler @scale="scale = $event" />
        </div>
      </div>
      <div class="image-notes">
        <h2 class="gl-font-size-20 font-weight-bold mt-0">{{ issue.title }}</h2>
        <a class="text-tertiary text-decoration-none mb-3 d-block" :href="issue.webUrl">{{
          issue.webPath
        }}</a>
        <participants
          :participants="discussionParticipants"
          :show-participant-label="false"
          class="mb-4"
        />
        <template v-if="renderDiscussions">
          <design-discussion
            v-for="(discussion, index) in discussions"
            :key="discussion.id"
            :discussion="discussion"
            :design-id="id"
            :noteable-id="design.id"
            :discussion-index="index + 1"
            :markdown-preview-path="markdownPreviewPath"
            @error="onDiffNoteError"
          />
          <apollo-mutation
            v-if="annotationCoordinates"
            v-slot="{ mutate, loading }"
            :mutation="$options.createImageDiffNoteMutation"
            :variables="{
              input: mutationPayload,
            }"
            :update="addImageDiffNoteToStore"
            @done="closeCommentForm"
            @error="onDiffNoteError"
          >
            <design-reply-form
              v-model="comment"
              :is-saving="loading"
              :markdown-preview-path="markdownPreviewPath"
              @submitForm="mutate()"
              @cancelForm="closeCommentForm"
            />
          </apollo-mutation>
        </template>
        <h2 v-else class="new-discussion-disclaimer gl-font-size-14 m-0">
          {{ __("Click the image where you'd like to start a new discussion") }}
        </h2>
      </div>
    </template>
  </div>
</template>
