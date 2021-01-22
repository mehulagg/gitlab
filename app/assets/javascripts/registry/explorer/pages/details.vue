<script>
import { GlKeysetPagination, GlResizeObserverDirective } from '@gitlab/ui';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import createFlash from '~/flash';
import Tracking from '~/tracking';
import { joinPaths } from '~/lib/utils/url_utility';
import DeleteAlert from '../components/details_page/delete_alert.vue';
import PartialCleanupAlert from '../components/details_page/partial_cleanup_alert.vue';
import DeleteModal from '../components/details_page/delete_modal.vue';
import DetailsHeader from '../components/details_page/details_header.vue';
import TagsList from '../components/details_page/tags_list.vue';
import TagsLoader from '../components/details_page/tags_loader.vue';
import EmptyTagsState from '../components/details_page/empty_tags_state.vue';
import StatusAlert from '../components/details_page/status_alert.vue';
import DeleteImage from '../components/delete_image.vue';

import getContainerRepositoryDetailsQuery from '../graphql/queries/get_container_repository_details.query.graphql';
import deleteContainerRepositoryTagsMutation from '../graphql/mutations/delete_container_repository_tags.mutation.graphql';

import {
  ALERT_SUCCESS_TAG,
  ALERT_DANGER_TAG,
  ALERT_SUCCESS_TAGS,
  ALERT_DANGER_TAGS,
  ALERT_DANGER_IMAGE,
  GRAPHQL_PAGE_SIZE,
  FETCH_IMAGES_LIST_ERROR_MESSAGE,
  UNFINISHED_STATUS,
} from '../constants/index';

export default {
  name: 'RegistryDetailsPage',
  components: {
    DeleteAlert,
    PartialCleanupAlert,
    DetailsHeader,
    GlKeysetPagination,
    DeleteModal,
    TagsList,
    TagsLoader,
    EmptyTagsState,
    StatusAlert,
    DeleteImage,
  },
  directives: {
    GlResizeObserver: GlResizeObserverDirective,
  },
  mixins: [Tracking.mixin()],
  inject: ['breadCrumbState', 'config'],
  apollo: {
    image: {
      query: getContainerRepositoryDetailsQuery,
      variables() {
        return this.queryVariables;
      },
      update(data) {
        return data.containerRepository;
      },
      result({ data }) {
        this.tagsPageInfo = data.containerRepository?.tags?.pageInfo;
        this.breadCrumbState.updateName(data.containerRepository?.name);
      },
      error() {
        createFlash({ message: FETCH_IMAGES_LIST_ERROR_MESSAGE });
      },
    },
  },
  data() {
    return {
      image: {},
      tagsPageInfo: {},
      itemsToBeDeleted: [],
      isMobile: false,
      mutationLoading: false,
      deleteAlertType: null,
      dismissPartialCleanupWarning: false,
      deleteImageAlert: false,
    };
  },
  computed: {
    queryVariables() {
      return {
        id: joinPaths(this.config.gidPrefix, `${this.$route.params.id}`),
        first: GRAPHQL_PAGE_SIZE,
      };
    },
    isLoading() {
      return this.$apollo.queries.image.loading || this.mutationLoading;
    },
    tags() {
      return this.image?.tags?.nodes || [];
    },
    showPartialCleanupWarning() {
      return (
        this.image?.expirationPolicyCleanupStatus === UNFINISHED_STATUS &&
        !this.dismissPartialCleanupWarning
      );
    },
    tracking() {
      return {
        label:
          this.itemsToBeDeleted?.length > 1 ? 'bulk_registry_tag_delete' : 'registry_tag_delete',
      };
    },
    showPagination() {
      return this.tagsPageInfo.hasPreviousPage || this.tagsPageInfo.hasNextPage;
    },
    disablePageActions() {
      return Boolean(this.image?.status);
    },
  },
  methods: {
    deleteTags(toBeDeleted) {
      this.deleteImageAlert = false;
      this.itemsToBeDeleted = this.tags.filter((tag) => toBeDeleted[tag.name]);
      this.track('click_button');
      this.$refs.deleteModal.show();
    },
    confirmDelete() {
      if (this.deleteImageAlert) {
        this.$refs.deleteImage.doDelete();
      } else {
        this.handleDeleteTag();
      }
    },
    async handleDeleteTag() {
      this.track('confirm_delete');
      const { itemsToBeDeleted } = this;
      this.itemsToBeDeleted = [];
      this.mutationLoading = true;
      try {
        const { data } = await this.$apollo.mutate({
          mutation: deleteContainerRepositoryTagsMutation,
          variables: {
            id: this.queryVariables.id,
            tagNames: itemsToBeDeleted.map((i) => i.name),
          },
          awaitRefetchQueries: true,
          refetchQueries: [
            {
              query: getContainerRepositoryDetailsQuery,
              variables: this.queryVariables,
            },
          ],
        });

        if (data?.destroyContainerRepositoryTags?.errors[0]) {
          throw new Error();
        }
        this.deleteAlertType =
          itemsToBeDeleted.length === 0 ? ALERT_SUCCESS_TAG : ALERT_SUCCESS_TAGS;
      } catch (e) {
        this.deleteAlertType = itemsToBeDeleted.length === 0 ? ALERT_DANGER_TAG : ALERT_DANGER_TAGS;
      }

      this.mutationLoading = false;
    },
    handleResize() {
      this.isMobile = GlBreakpointInstance.getBreakpointSize() === 'xs';
    },
    fetchNextPage() {
      if (this.tagsPageInfo?.hasNextPage) {
        this.$apollo.queries.image.fetchMore({
          variables: {
            after: this.tagsPageInfo?.endCursor,
            first: GRAPHQL_PAGE_SIZE,
          },
          updateQuery(previousResult, { fetchMoreResult }) {
            return fetchMoreResult;
          },
        });
      }
    },
    fetchPreviousPage() {
      if (this.tagsPageInfo?.hasPreviousPage) {
        this.$apollo.queries.image.fetchMore({
          variables: {
            first: null,
            before: this.tagsPageInfo?.startCursor,
            last: GRAPHQL_PAGE_SIZE,
          },
          updateQuery(previousResult, { fetchMoreResult }) {
            return fetchMoreResult;
          },
        });
      }
    },
    deleteImage() {
      this.deleteImageAlert = true;
      this.itemsToBeDeleted = [{ path: this.image.path }];
      this.$refs.deleteModal.show();
    },
    deleteImageError() {
      this.deleteAlertType = ALERT_DANGER_IMAGE;
    },
    deleteImageIniit() {
      this.itemsToBeDeleted = [];
      this.mutationLoading = true;
    },
  },
};
</script>

<template>
  <div v-gl-resize-observer="handleResize" class="gl-my-3">
    <delete-alert
      v-model="deleteAlertType"
      :garbage-collection-help-page-path="config.garbageCollectionHelpPagePath"
      :is-admin="config.isAdmin"
      class="gl-my-2"
    />

    <partial-cleanup-alert
      v-if="showPartialCleanupWarning"
      :run-cleanup-policies-help-page-path="config.runCleanupPoliciesHelpPagePath"
      :cleanup-policies-help-page-path="config.cleanupPoliciesHelpPagePath"
      @dismiss="dismissPartialCleanupWarning = true"
    />

    <status-alert v-if="image.status" :status="image.status" />

    <details-header
      :image="image"
      :metadata-loading="isLoading"
      :disabled="disablePageActions"
      @delete="deleteImage"
    />

    <tags-loader v-if="isLoading" />
    <template v-else>
      <empty-tags-state v-if="tags.length === 0" :no-containers-image="config.noContainersImage" />
      <template v-else>
        <tags-list
          :tags="tags"
          :is-mobile="isMobile"
          :disabled="disablePageActions"
          @delete="deleteTags"
        />
        <div class="gl-display-flex gl-justify-content-center">
          <gl-keyset-pagination
            v-if="showPagination"
            :has-next-page="tagsPageInfo.hasNextPage"
            :has-previous-page="tagsPageInfo.hasPreviousPage"
            class="gl-mt-3"
            @prev="fetchPreviousPage"
            @next="fetchNextPage"
          />
        </div>
      </template>
    </template>

    <delete-image
      :id="image.id"
      ref="deleteImage"
      :use-update-fn="true"
      @start="deleteImageIniit"
      @error="deleteImageError"
      @end="mutationLoading = false"
    />

    <delete-modal
      ref="deleteModal"
      :items-to-be-deleted="itemsToBeDeleted"
      :delete-image="deleteImageAlert"
      @confirmDelete="confirmDelete"
      @cancel="track('cancel_delete')"
    />
  </div>
</template>
