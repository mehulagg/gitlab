<script>
import { mapState, mapGetters } from 'vuex';

import IssuableBody from '~/issue_show/components/app.vue';
import { PathIdSeparator } from '~/related_issues/constants';

import EpicSidebar from './epic_sidebar.vue';

export default {
  PathIdSeparator,
  components: {
    IssuableBody,
    EpicSidebar,
  },
  computed: {
    ...mapState([
      'endpoint',
      'updateEndpoint',
      'groupPath',
      'markdownPreviewPath',
      'markdownDocsPath',
      'canUpdate',
      'canDestroy',
      'canAdmin',
      'initialTitleHtml',
      'initialTitleText',
      'initialDescriptionHtml',
      'initialDescriptionText',
      'lockVersion',
      'sidebarCollapsed',
    ]),
    ...mapGetters(['isUserSignedIn']),
  },
};
</script>

<template>
  <div>
    <div class="issuable-details detail-page-description content-block">
      <issuable-body
        :endpoint="endpoint"
        :update-endpoint="updateEndpoint"
        :project-path="groupPath"
        :project-id="0"
        :markdown-preview-path="markdownPreviewPath"
        :markdown-docs-path="markdownDocsPath"
        :can-update="canUpdate"
        :can-destroy="canDestroy"
        :show-delete-button="canDestroy"
        :initial-title-html="initialTitleHtml"
        :initial-title-text="initialTitleText"
        :lock-version="lockVersion"
        :initial-description-html="initialDescriptionHtml"
        :initial-description-text="initialDescriptionText"
        :show-inline-edit-button="true"
        :enable-autocomplete="true"
        project-namespace
        issuable-ref
        issuable-type="epic"
      />
    </div>
    <epic-sidebar />
  </div>
</template>
