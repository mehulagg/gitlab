<script>
import { GlLink, GlSprintf } from '@gitlab/ui';
import {first}  from 'lodash'
import { s__ } from '~/locale';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import HistoryItem from '~/vue_shared/components/registry/history_item.vue';

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
    tooManyPipelinesMessage: s__('PackageRegistry|Paackage has %{number} archived commits, pipeline builds and registry updateds'),
    updatedByCommitText: s__(
      'PackageRegistry|Updated by commit %{link} on branch %{branch}',
    ),
    updatedByPipelineText: s__(
      'PackageRegistry|Updated built by pipeline %{link} triggered %{datetime} by %{author}',
    ),
    updatePublishText: s__('PackageRegistry|%{name} version %{version} update was published to the registry %{datetime}'),

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
    firstPipeline() {
      return first(this.packageEntity.pipelines)
    },
    lastPipelines() {
      return this.packageEntity.pipelines.slice(-5)
    },
    shouldShowLastPipeline() {
      return false
    },
    updatedDate() {
      if (this.lastPipeline) {
        return new Date(this.lastPipeline.created_at).getTime() >
          new Date(this.packageEntity.updated_at)
          ? this.lastPipeline.created_at
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
      <history-item icon="pencil" data-testid="updated-at">
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
      <template v-if="firstPipeline">
        <history-item icon="commit" data-testid="commit">
          <gl-sprintf :message="$options.i18n.createdByCommitText">
            <template #link>
              <gl-link :href="firstPipeline.project.commit_url">{{ firstPipeline.sha }}</gl-link>
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
      <template v-if="shouldShowLastPipeline">
        <history-item icon="commit" data-testid="commit">
          <gl-sprintf :message="$options.i18n.lastUpdatedByCommitText">
            <template #link>
              <gl-link :href="lastPipeline.project.commit_url">{{ lastPipeline.sha }}</gl-link>
            </template>
            <template #branch>
              <strong>{{ lastPipeline.ref }}</strong>
            </template>
          </gl-sprintf>
        </history-item>
        <history-item icon="pipeline" data-testid="pipeline">
          <gl-sprintf :message="$options.i18n.lastUpdatedByPipelineText">
            <template #link>
              <gl-link :href="lastPipeline.project.pipeline_url">#{{ lastPipeline.id }}</gl-link>
            </template>
            <template #datetime>
              <time-ago-tooltip :time="lastPipeline.created_at" />
            </template>
            <template #author>{{ lastPipeline.user.name }}</template>
          </gl-sprintf>
        </history-item>
      </template>
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
    </ul>
  </div>
</template>
