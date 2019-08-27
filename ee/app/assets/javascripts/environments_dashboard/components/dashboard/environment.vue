<script>
import _ from 'lodash-es';
import { GlTooltipDirective, GlLink } from '@gitlab/ui';
import { s__, __, sprintf } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import timeagoMixin from '~/vue_shared/mixins/timeago';
import UserAvatarLink from '~/vue_shared/components/user_avatar/user_avatar_link.vue';
import Commit from '~/vue_shared/components/commit.vue';
import Alerts from 'ee/vue_shared/dashboards/components/alerts.vue';
import TimeAgo from 'ee/vue_shared/dashboards/components/time_ago.vue';
import { STATUS_FAILED, STATUS_RUNNING } from 'ee/vue_shared/dashboards/constants';
import ProjectPipeline from 'ee/vue_shared/dashboards/components/project_pipeline.vue';
import EnvironmentHeader from './environment_header.vue';

export default {
  components: {
    EnvironmentHeader,
    UserAvatarLink,
    GlLink,
    Commit,
    Alerts,
    ProjectPipeline,
    TimeAgo,
    Icon,
  },
  directives: {
    'gl-tooltip': GlTooltipDirective,
  },
  mixins: [timeagoMixin],
  props: {
    environment: {
      type: Object,
      required: true,
    },
  },
  tooltips: {
    timeAgo: __('Finished'),
    triggerer: __('Triggerer'),
    job: s__('EnvironmentsDashboard|Job: %{job}'),
  },
  noDeploymentMessage: __('This environment has no deployments yet.'),
  computed: {
    hasPipelineFailed() {
      return (
        this.lastPipeline &&
        this.lastPipeline.details &&
        this.lastPipeline.details.status &&
        this.lastPipeline.details.status.group === STATUS_FAILED
      );
    },
    hasPipelineErrors() {
      return this.environment.alert_count > 0;
    },
    cardClasses() {
      return {
        'dashboard-card-body-warning': !this.hasPipelineFailed && this.hasPipelineErrors,
        'dashboard-card-body-failed': this.hasPipelineFailed,
        'bg-secondary': !this.hasPipelineFailed && !this.hasPipelineErrors,
      };
    },
    user() {
      return this.lastDeployment && !_.isEmpty(this.lastDeployment.user)
        ? this.lastDeployment.user
        : null;
    },
    lastPipeline() {
      return !_.isEmpty(this.environment.last_pipeline) ? this.environment.last_pipeline : null;
    },
    lastDeployment() {
      return !_.isEmpty(this.environment.last_deployment) ? this.environment.last_deployment : null;
    },
    deployable() {
      return !_.isEmpty(this.lastDeployment.deployable) ? this.lastDeployment.deployable : null;
    },
    commit() {
      return !_.isEmpty(this.lastDeployment.commit) ? this.lastDeployment.commit : {};
    },
    jobTooltip() {
      return sprintf(this.$options.tooltips.job, { job: this.buildName });
    },
    commitRef() {
      return this.lastDeployment && !_.isEmpty(this.lastDeployment.commit)
        ? {
            ...this.lastDeployment.commit,
            ...this.lastDeployment.ref,
            ref_url: this.lastDeployment.ref.ref_path,
          }
        : {};
    },
    finishedTime() {
      return this.deployable.updated_at;
    },
    finishedTimeTitle() {
      return this.tooltipTitle(this.finishedTime);
    },
    shouldShowTimeAgo() {
      return (
        this.deployable &&
        this.deployable.status &&
        this.deployable.status.group !== STATUS_RUNNING &&
        this.finishedTime
      );
    },
    buildName() {
      if (
        this.environment &&
        this.environment.last_deployment &&
        this.environment.last_deployment.deployable
      ) {
        const { deployable } = this.environment.last_deployment;
        return `${deployable.name} #${deployable.id}`;
      }
      return '';
    },
  },
};
</script>
<template>
  <div class="dashboard-card card border-0">
    <environment-header
      :environment="environment"
      :has-pipeline-failed="hasPipelineFailed"
      :has-errors="hasPipelineErrors"
    />

    <div :class="cardClasses" class="dashboard-card-body card-body">
      <div v-if="lastDeployment" class="row">
        <div class="col-1 align-self-center">
          <user-avatar-link
            v-if="user"
            :link-href="user.path"
            :img-src="user.avatar_url"
            :tooltip-text="user.name"
            :img-size="32"
          />
        </div>

        <div class="col-10 col-sm-6 pr-0 pl-5 align-self-center align-middle ci-table">
          <div class="branch-commit">
            <icon name="work" />
            <gl-link v-gl-tooltip="jobTooltip" :href="deployable.build_path" class="str-truncated">
              {{ buildName }}
            </gl-link>
          </div>
          <commit
            :tag="commitRef.tag"
            :commit-ref="commitRef"
            :short-sha="commit.short_id"
            :commit-url="commit.commit_url"
            :title="commit.title"
            :author="commit.author"
            :show-branch="true"
          />
        </div>

        <div class="col-sm-5 pl-0 text-right align-self-center d-none d-sm-block">
          <time-ago
            v-if="shouldShowTimeAgo"
            :time="finishedTime"
            :tooltip-text="$options.tooltips.timeAgo"
          />
          <alerts :count="environment.alert_count" :last-alert="environment.last_alert" />
        </div>

        <div v-if="lastPipeline" class="col-12">
          <project-pipeline
            :project-name="environment.name_with_namespace"
            :last-pipeline="lastPipeline"
            :has-pipeline-failed="hasPipelineFailed"
          />
        </div>
      </div>

      <div v-else class="h-100 d-flex justify-content-center align-items-center">
        <div class="text-plain text-metric text-center bold w-75">
          {{ $options.noDeploymentMessage }}
        </div>
      </div>
    </div>
  </div>
</template>
