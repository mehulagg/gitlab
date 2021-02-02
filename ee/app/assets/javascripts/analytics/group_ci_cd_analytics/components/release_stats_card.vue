<script>
import { GlCard, GlLoadingIcon } from '@gitlab/ui';
import { sprintf, n__, s__ } from '~/locale';
import createFlash from '~/flash';
import groupReleaseStatsQuery from '../graphql/group_release_stats.query.graphql';

export default {
  name: 'ReleaseStatsCard',
  components: {
    GlCard,
    GlLoadingIcon,
  },
  inject: {
    fullPath: {
      default: '',
    },
  },
  apollo: {
    rawStats: {
      query: groupReleaseStatsQuery,
      variables() {
        return {
          fullPath: this.fullPath,
        };
      },
      update(data) {
        return data.group.stats.releaseStats;
      },
      error(error) {
        this.errored = true;
        createFlash({
          message: s__('CICDAnalytics|Something went wrong while fetching release statistics'),
          captureError: true,
          error,
        });
      },
    },
  },
  data() {
    return {
      errored: false,
    };
  },
  computed: {
    isLoading() {
      return this.$apollo.queries.rawStats.loading;
    },
    releasesCountStat() {
      if (this.errored) {
        return '?';
      }

      return this.rawStats?.releasesCount.toString() || '';
    },
    releasesPercentageStat() {
      if (this.errored) {
        return '?';
      }

      if (this.rawStats?.releasesPercentage) {
        return sprintf(s__('CICDAnalytics|%{percent}%'), {
          percent: this.rawStats?.releasesPercentage,
        });
      }

      return '';
    },
    stats() {
      return [
        {
          stat: this.releasesCountStat,
          title: n__(
            'CICDAnalytics|Release',
            'CICDAnalytics|Releases',
            this.rawStats?.releasesCount || 0,
          ),
        },
        {
          stat: this.releasesPercentageStat,
          title: s__('CICDAnalytics|Projects with releases'),
        },
      ];
    },
  },
};
</script>
<template>
  <div>
    <gl-card>
      <template #header>
        <div class="gl-display-flex gl-align-items-baseline">
          <h1 class="gl-m-0 gl-mr-5 gl-font-lg">{{ s__('CICDAnalytics|Releases') }}</h1>
          <h2 class="gl-m-0 gl-font-base gl-text-gray-500 gl-font-weight-normal">
            {{ s__('CICDAnalytics|All time') }}
          </h2>
        </div>
      </template>

      <div
        class="gl-display-flex gl-flex-direction-column gl-flex-direction-column gl-sm-flex-direction-row"
      >
        <div
          v-for="(stat, index) of stats"
          class="gl-flex-grow-1 gl-text-center gl-display-flex gl-flex-direction-column"
          :class="{ 'gl-xs-mb-4': index != stats.length - 1 }"
        >
          <span class="gl-font-size-h-display">
            <template v-if="isLoading">
              <span class="gl-display-flex gl-justify-content-center gl-align-items-center">
                &ZeroWidthSpace;
                <gl-loading-icon size="md" />
              </span>
            </template>
            <template v-else>
              {{ stat.stat }}
            </template>
          </span>
          <span>{{ stat.title }}</span>
        </div>
      </div>
    </gl-card>
  </div>
</template>
