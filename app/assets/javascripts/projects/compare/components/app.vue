<script>
import { GlButton } from '@gitlab/ui';
import csrf from '~/lib/utils/csrf';
import RevisionCard from './revision_card.vue';

export default {
  csrf,
  components: {
    RevisionCard,
    GlButton,
  },
  props: {
    projectCompareIndexPath: {
      type: String,
      required: true,
    },
    refsProjectPath: {
      type: String,
      required: true,
    },
    paramsFrom: {
      type: String,
      required: false,
      default: null,
    },
    paramsTo: {
      type: String,
      required: false,
      default: null,
    },
    projectMergeRequestPath: {
      type: String,
      required: true,
    },
    createMrPath: {
      type: String,
      required: true,
    },
    defaultProject: {
      type: Object,
      required: true,
    },
    projects: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      from: {
        projects: this.projects,
        selectedProject: this.defaultProject,
        branch: this.paramsFrom,
        refsProjectPath: this.refsProjectPath,
      },
      to: {
        selectedProject: this.defaultProject,
        branch: this.paramsTo,
        refsProjectPath: this.refsProjectPath,
      },
    };
  },
  methods: {
    onSubmit() {
      this.$refs.form.submit();
    },
    onSelectProject({ direction, project }) {
      this[direction].refsProjectPath = `/${project.name}/refs`;
      this[direction].selectedProject = project;
    },
    onSwapRevision() {
      [this.from, this.to] = [this.to, this.from]; // swaps 'from' and 'to'
    },
  },
};
</script>

<template>
  <form
    ref="form"
    class="js-requires-input js-signature-container"
    method="POST"
    :action="projectCompareIndexPath"
  >
    <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
    <div
      class="gl-lg-flex-direction-row gl-lg-display-flex gl-align-items-center compare-revision-cards"
    >
      <revision-card
        :refs-project-path="to.refsProjectPath"
        revision-text="Source"
        params-name="to"
        :params-branch="to.branch"
        :projects="to.projects"
        :selected-project="to.selectedProject"
        @selectProject="onSelectProject"
      />
      <div
        class="compare-ellipsis gl-display-flex gl-justify-content-center gl-align-items-center gl-my-4 gl-md-my-0"
        data-testid="ellipsis"
      >
        ...
      </div>
      <revision-card
        :refs-project-path="from.refsProjectPath"
        revision-text="Target"
        params-name="from"
        :params-branch="from.branch"
        :projects="from.projects"
        :selected-project="from.selectedProject"
        @selectProject="onSelectProject"
      />
    </div>
    <div class="gl-mt-4">
      <gl-button category="primary" variant="success" @click="onSubmit">
        {{ s__('CompareRevisions|Compare') }}
      </gl-button>
      <gl-button
        data-testid="swapRevisionsButton"
        class="btn btn-default gl-button gl-ml-3"
        @click="onSwapRevision"
      >
        {{ s__('CompareRevisions|Swap revisions') }}
      </gl-button>
      <gl-button
        v-if="projectMergeRequestPath"
        :href="projectMergeRequestPath"
        data-testid="projectMrButton"
        class="btn btn-default gl-button"
      >
        {{ s__('CompareRevisions|View open merge request') }}
      </gl-button>
      <gl-button
        v-else-if="createMrPath"
        :href="createMrPath"
        data-testid="createMrButton"
        class="btn btn-default gl-button"
      >
        {{ s__('CompareRevisions|Create merge request') }}
      </gl-button>
    </div>
  </form>
</template>
