<script>
import { GlBadge, GlTabs, GlTab, GlLink, GlIcon } from '@gitlab/ui';
import { mapActions, mapGetters, mapState } from 'vuex';

import UnscannedProjectsTabContent from './unscanned_projects_tab_content.vue';

export default {
  components: { GlBadge, GlTabs, GlTab, GlLink, GlIcon, UnscannedProjectsTabContent },
  props: {
    endpoint: {
      type: String,
      required: true,
    },
    helpPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    ...mapState('unscannedProjects', ['isLoading']),
    ...mapGetters('unscannedProjects', [
      'outdatedProjects',
      'outdatedProjectsCount',
      'untestedProjects',
      'untestedProjectsCount',
    ]),
    hasOutdatedProjects() {
      return this.outdatedProjectsCount > 0;
    },
    hasUntestedProjects() {
      return this.untestedProjectsCount > 0;
    },
  },
  created() {
    this.fetchUnscannedProjects(this.endpoint);
  },
  methods: {
    ...mapActions('unscannedProjects', ['fetchUnscannedProjects']),
  },
};
</script>
<template>
  <section class="border rounded">
    <header class="px-3 pt-3 mb-0">
      <h4 class="my-0">
        {{ s__('UnscannedProjects|Project scanning') }}
        <gl-link
          v-if="helpPath"
          :href="helpPath"
          :title="__('Project scanning help page')"
          target="_blank"
          ><gl-icon name="question" :size="12" class="align-top"
        /></gl-link>
      </h4>
      <p class="text-secondary mb-0">
        {{ s__('UnscannedProjects|Default branch scanning by project') }}
      </p>
    </header>
    <div>
      <gl-tabs>
        <gl-tab ref="outdatedProjectsTab" title-item-class="ml-3">
          <template #title>
            {{ s__('UnscannedProjects|Out of date') }}
            <gl-badge
              v-if="!isLoading"
              ref="outdatedProjectsCount"
              size="sm"
              class="gl-tab-counter-badge"
              pill
              >{{ outdatedProjectsCount }}
            </gl-badge>
          </template>
          <unscanned-projects-tab-content :is-loading="isLoading" :is-empty="!hasOutdatedProjects">
            <div v-for="dateRange in outdatedProjects" :key="dateRange.fromDay" class="mb-3">
              <h5 class="m-0">{{ dateRange.description }}</h5>
              <ul class="list-unstyled mb-0">
                <li v-for="project in dateRange.projects" :key="project.id" class="mt-1">
                  <gl-link target="_blank" :href="`${project.fullPath}/pipelines`">{{
                    project.fullName
                  }}</gl-link>
                </li>
              </ul>
            </div>
          </unscanned-projects-tab-content>
        </gl-tab>
        <gl-tab ref="untestedProjectsTab" title-item-class="ml-3">
          <template #title>
            {{ s__('UnscannedProjects|Untested') }}
            <gl-badge
              v-if="!isLoading"
              ref="untestedProjectsCount"
              size="sm"
              class="gl-tab-counter-badge"
              pill
              >{{ untestedProjectsCount }}
            </gl-badge>
          </template>
          <unscanned-projects-tab-content :is-loading="isLoading" :is-empty="!hasUntestedProjects">
            <ul class="list-unstyled m-0">
              <li v-for="project in untestedProjects" :key="project.id" class="mb-1">
                <gl-link target="_blank" :href="`${project.fullPath}/security/configuration`">{{
                  project.fullName
                }}</gl-link>
              </li>
            </ul>
          </unscanned-projects-tab-content>
        </gl-tab>
      </gl-tabs>
    </div>
  </section>
</template>
