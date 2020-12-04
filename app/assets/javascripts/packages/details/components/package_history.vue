<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import { first } from 'lodash';
import { s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import HistoryItem from '~/vue_shared/components/registry/history_item.vue';
import { HISTORY_PIPELINES_LIMIT } from '~/packages/details/constants';
import History_item from '../../../vue_shared/components/registry/history_item.vue';

export default {
  name: 'PackageHistory',
  i18n: {
    createdOn: s__('PackageRegistry|%{name} version %{version} was first created %{datetime}'),
    updatedAtText: s__('PackageRegistry|%{name} version %{version} was updated %{datetime}'),
    createdByCommitText: s__('PackageRegistry|Created by commit %{link} on branch %{branch}'),
    createdByPipelineText: s__(
      'PackageRegistry|Built by pipeline %{link} triggered %{datetime} by %{author}',
    ),
    publishText: s__('PackageRegistry|Published to the %{project} Package Registry %{datetime}'),
    archivedPipelineMessage: s__(
      'PackageRegistry|Paackage has %{number} archived commits, pipeline builds and registry updateds',
    ),
    updatedByCommitText: s__('PackageRegistry|Updated by commit %{link} on branch %{branch}'),
    updatedByPipelineText: s__(
      'PackageRegistry|Updated built by pipeline %{link} triggered %{datetime} by %{author} %{datetime}',
    ),
    updatePublishText: s__(
      'PackageRegistry|%{name} version %{version} update was published to the registry %{datetime}',
    ),
  },
  components: {
    GlLink,
    GlSprintf,
    HistoryItem,
    TimeAgoTooltip,
  },
  props: {
    packageEntity: {
      type: Object,
      required: true,
    },
    projectName: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      showDescription: false,
    };
  },
  computed: {
    pipelines() {
      return this.packageEntity.pipelines || [];
    },
    firstPipeline() {
      return first(this.pipelines);
    },
    lastPipelines() {
      return this.pipelines
        .slice(-HISTORY_PIPELINES_LIMIT)
        .filter(p => p.id !== this.firstPipeline.id);
    },
    showPipelinesInfo() {
      return Boolean(this.firstPipeline?.id);
    },
    archiviedLines() {
      return Math.max(this.pipelines.length - HISTORY_PIPELINES_LIMIT - 1, 0);
    },
    updatedDate() {
      if (this.firstPipeline) {
        return new Date(this.firstPipeline.created_at).getTime() >
          new Date(this.packageEntity.updated_at)
          ? this.firstPipeline.created_at
          : this.packageEntity.updated_at;
      }
      return this.packageEntity.updated_at;
    },
  },
};
</script>

<template>
  <div class="issuable-discussion">
    <h3 class="gl-font-lg" data-testid="title">{{ __('History') }}</h3>
    <ul class="timeline main-notes-list notes gl-mb-4" data-testid="timeline">
      <history-item icon="clock" data-testid="created-on">
        <gl-sprintf :message="$options.i18n.createdOn">
          <template #name>
            <strong>{{ packageEntity.name }}</strong>
          </template>
          <template #version>
            <strong>{{ packageEntity.version }}</strong>
          </template>
          <template #datetime>
            <time-ago-tooltip :time="packageEntity.created_at" />
          </template>
        </gl-sprintf>
      </history-item>

      <template v-if="showPipelinesInfo">
        <!-- FIRST PIPELINE BLOCK -->
        <history-item icon="commit" data-testid="commit">
          <gl-sprintf :message="$options.i18n.createdByCommitText">
            <template #link>
              <gl-link :href="firstPipeline.project.commit_url"
                >#{{ firstPipeline.sha.slice(0, 8) }}</gl-link
              >
            </template>
            <template #branch>
              <strong>{{ firstPipeline.ref }}</strong>
            </template>
          </gl-sprintf>
        </history-item>
        <history-item icon="pipeline" data-testid="pipeline">
          <gl-sprintf :message="$options.i18n.createdByPipelineText">
            <template #link>
              <gl-link :href="firstPipeline.project.pipeline_url">#{{ firstPipeline.id }}</gl-link>
            </template>
            <template #datetime>
              <time-ago-tooltip :time="firstPipeline.created_at" />
            </template>
            <template #author>{{ firstPipeline.user.name }}</template>
          </gl-sprintf>
        </history-item>
      </template>
      <!-- END OF FIRST PIPELINE BLOCK -->

      <history-item v-if="lastPipelines.length === 0" icon="pencil" data-testid="updated-at">
        <gl-sprintf :message="$options.i18n.updatedAtText">
          <template #name>
            <strong>{{ packageEntity.name }}</strong>
          </template>
          <template #version>
            <strong>{{ packageEntity.version }}</strong>
          </template>
          <template #datetime>
            <time-ago-tooltip :time="updatedDate" />
          </template>
        </gl-sprintf>
      </history-item>

      <!-- PUBLISHED LINE -->
      <history-item icon="package" data-testid="published">
        <gl-sprintf :message="$options.i18n.publishText">
          <template #project>
            <strong>{{ projectName }}</strong>
          </template>
          <template #datetime>
            <time-ago-tooltip :time="packageEntity.created_at" />
          </template>
        </gl-sprintf>
      </history-item>

      <history-item v-if="archiviedLines" icon="history" data-testid="archived">
        <gl-sprintf :message="$options.i18n.archivedPipelineMessage">
          <template #number>
            <strong>{{ archiviedLines }}</strong>
          </template>
        </gl-sprintf>
      </history-item>

      <!-- PIPELINS LIST BLOCK -->

      <template v-for="pipeline in lastPipelines">
        <history-item :key="`commit-${pipeline.id}`" icon="commit" data-testid="commit">
          <gl-sprintf :message="$options.i18n.updatedByCommitText">
            <template #link>
              <gl-link :href="pipeline.project.commit_url">#{{ pipeline.sha.slice(0, 8) }}</gl-link>
            </template>
            <template #branch>
              <strong>{{ pipeline.ref }}</strong>
            </template>
            <template #datetime>
              <time-ago-tooltip :time="pipeline.created_at" />
            </template>
          </gl-sprintf>
        </history-item>
        <history-item :key="`pipeline-${pipeline.id}`" icon="pipeline" data-testid="pipeline">
          <gl-sprintf :message="$options.i18n.updatedByPipelineText">
            <template #link>
              <gl-link :href="pipeline.project.pipeline_url">#{{ pipeline.id }}</gl-link>
            </template>
            <template #datetime>
              <time-ago-tooltip :time="pipeline.created_at" />
            </template>
            <template #author>{{ pipeline.user.name }}</template>
          </gl-sprintf>
        </history-item>

        <history-item :key="`updated-at-${pipeline.id}`" icon="pencil" data-testid="updated-at">
          <gl-sprintf :message="$options.i18n.updatePublishText">
            <template #name>
              <strong>{{ packageEntity.name }}</strong>
            </template>
            <template #version>
              <strong>{{ packageEntity.version }}</strong>
            </template>
            <template #datetime>
              <time-ago-tooltip :time="pipeline.created_at" />
            </template>
          </gl-sprintf>
        </history-item>
      </template>
    </ul>
  </div>
</template>
