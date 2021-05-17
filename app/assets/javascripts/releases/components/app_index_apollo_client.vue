<script>
import { GlEmptyState, GlLink, GlButton, GlKeysetPagination } from '@gitlab/ui';
import allReleasesQuery from 'shared_queries/releases/all_releases.query.graphql';
import { convertAllReleasesGraphQLResponse } from '~/releases/util';
import { __ } from '~/locale';
import ReleaseBlock from './release_block.vue';
import ReleaseSkeletonLoader from './release_skeleton_loader.vue';
import ReleasesPaginationApolloClient from './releases_pagination_apollo_client.vue';
import ReleasesSort from './releases_sort.vue';
import { PAGE_SIZE } from '~/releases/constants';
import createFlash from '~/flash';

export default {
  name: 'ReleasesIndexApolloClientApp',
  components: {
    GlEmptyState,
    GlLink,
    GlButton,
    ReleaseBlock,
    ReleasesPaginationApolloClient,
    ReleaseSkeletonLoader,
    ReleasesSort,
    GlKeysetPagination,
  },
  inject: {
    projectPath: {
      default: '',
    },
    documentationPath: {
      default: '',
    },
    illustrationPath: {
      default: '',
    },
    newReleasePath: {
      default: '',
    },
  },
  apollo: {
    graphqlResponse: {
      query: allReleasesQuery,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        return { data };
      },
      error(error) {
        this.hasError = true;

        createFlash({
          message: __('An error occurred while fetching the releases. Please try again.'),
          captureError: true,
          error,
        });
      },
    },
  },
  data() {
    return {
      hasError: false,
      cursors: {},
    };
  },
  computed: {
    queryVariables() {
      return {
        fullPath: this.projectPath,
        first: 1,
      };

      let firstLastParams;
      if (!this.cursors.before) {
        firstLastParams = { first: PAGE_SIZE };
      } else if (!this.cursors.after) {
        firstLastParams = { last: PAGE_SIZE };
      } else {
        throw new Error(
          '`this.cursors.before` and `this.cursors.after` cannot both be truthy. These query variables cannot be used together.',
        );
      }

      return {
        fullPath: this.projectPath,
        ...this.cursors,
        ...firstLastParams,
      };
    },
    isLoading() {
      return this.$apollo.queries.graphqlResponse.loading;
    },
    releases() {
      if (!this.graphqlResponse) {
        return [];
      }

      return convertAllReleasesGraphQLResponse(this.graphqlResponse).data;
    },
    pageInfo() {
      return this.graphqlResponse?.data.project.releases.pageInfo;
    },
    shouldRenderEmptyState() {
      return !this.releases.length && !this.hasError && !this.isLoading;
    },
    shouldRenderSuccessState() {
      return this.releases.length && !this.isLoading && !this.hasError;
    },
    emptyStateText() {
      return __(
        "Releases are based on Git tags and mark specific points in a project's development history. They can contain information about the type of changes and can also deliver binaries, like compiled versions of your software.",
      );
    },
    showPagination() {
      return !this.isLoading && (this.pageInfo?.hasPreviousPage || this.pageInfo?.hasNextPage);
    },
  },
  created() {
    // TODO: read before/after parameter from URL for initial load.
    // Or, maybe always reference these parameters instead of storing
    // them as `data`? (Similar to what the old component did).
    window.addEventListener('popstate', this.fetchReleases);
  },
};
</script>
<template>
  <div class="flex flex-column mt-2">
    <div class="gl-align-self-end gl-mb-3">
      <!-- TODO: Implement a new sort component that doesn't rely on Vuex -->
      <!-- <releases-sort class="gl-mr-2" @sort:changed="onSortChanged" /> -->
      <div class="gl-flex-grow-1 TEMPORARY!"></div>

      <gl-button
        v-if="newReleasePath"
        :href="newReleasePath"
        :aria-describedby="shouldRenderEmptyState && 'releases-description'"
        category="primary"
        variant="success"
        data-testid="new-release-button"
      >
        {{ __('New release') }}
      </gl-button>
    </div>

    <release-skeleton-loader v-if="isLoading" />

    <gl-empty-state
      v-else-if="shouldRenderEmptyState"
      data-testid="empty-state"
      :title="__('Getting started with releases')"
      :svg-path="illustrationPath"
    >
      <template #description>
        <span id="releases-description">
          {{ emptyStateText }}
          <gl-link
            :href="documentationPath"
            :aria-label="__('Releases documentation')"
            target="_blank"
          >
            {{ __('More information') }}
          </gl-link>
        </span>
      </template>
    </gl-empty-state>

    <div v-else-if="shouldRenderSuccessState" data-testid="success-state">
      <release-block
        v-for="(release, index) in releases"
        :key="index"
        :release="release"
        :class="{ 'linked-card': releases.length > 1 && index !== releases.length - 1 }"
      />
    </div>

    <releases-pagination-apollo-client v-if="!isLoading" :page-info="pageInfo" v-model="cursors" />
  </div>
</template>
<style>
.linked-card::after {
  width: 1px;
  content: ' ';
  border: 1px solid #e5e5e5;
  height: 17px;
  top: 100%;
  position: absolute;
  left: 32px;
}
</style>
