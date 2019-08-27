<script>
import { sprintf, n__, s__, __ } from '~/locale';
import $ from 'jquery';
import _ from 'lodash-es';
import Icon from '~/vue_shared/components/icon.vue';
import { GlLoadingIcon, GlButton, GlAvatar } from '@gitlab/ui';
import Api from '~/api';
import { renderAvatar, renderIdenticon } from '~/helpers/avatar_helper';

export default {
  name: 'ProjectsDropdownFilter',
  components: {
    Icon,
    GlLoadingIcon,
    GlButton,
    GlAvatar,
  },
  props: {
    groupId: {
      type: Number,
      required: true,
    },
    multiSelect: {
      type: Boolean,
      required: false,
      default: false,
    },
    label: {
      type: String,
      required: false,
      default: s__('CycleAnalytics|project dropdown filter'),
    },
    queryParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      loading: true,
      selectedProjects: [],
    };
  },
  computed: {
    selectedProjectsLabel() {
      return this.selectedProjects.length
        ? sprintf(
            n__(
              'CycleAnalytics|%{projectName}',
              'CycleAnalytics|%d projects selected',
              this.selectedProjects.length,
            ),
            { projectName: this.selectedProjects[0].name },
          )
        : this.selectedProjectsPlaceholder;
    },
    selectedProjectsPlaceholder() {
      return this.multiSelect ? __('Select projects') : __('Select a project');
    },
    isOnlyOneProjectSelected() {
      return this.selectedProjects.length === 1;
    },
  },
  mounted() {
    $(this.$refs.projectsDropdown).glDropdown({
      selectable: true,
      filterable: true,
      filterRemote: true,
      fieldName: 'project_id',
      multiSelect: this.multiSelect,
      search: {
        fields: ['name'],
      },
      clicked: this.onClick.bind(this),
      data: this.fetchData.bind(this),
      renderRow: group => this.rowTemplate(group),
      text: project => project.name,
      opened: e => e.target.querySelector('.dropdown-input-field').focus(),
    });
  },
  methods: {
    getSelectedProjects(selectedProject, isMarking) {
      return isMarking
        ? this.selectedProjects.concat([selectedProject])
        : this.selectedProjects.filter(project => project.id !== selectedProject.id);
    },
    singleSelectedProject(selectedObj, isMarking) {
      return isMarking ? [selectedObj] : [];
    },
    setSelectedProjects(selectedObj, isMarking) {
      this.selectedProjects = this.multiSelect
        ? this.getSelectedProjects(selectedObj, isMarking)
        : this.singleSelectedProject(selectedObj, isMarking);
    },
    onClick({ selectedObj, e, isMarking }) {
      e.preventDefault();
      this.setSelectedProjects(selectedObj, isMarking);
      this.$emit('selected', this.selectedProjects);
    },
    fetchData(term, callback) {
      this.loading = true;
      return Api.groupProjects(this.groupId, term, this.queryParams, projects => {
        this.loading = false;
        callback(projects);
      });
    },
    rowTemplate(project) {
      return `
          <li>
            <a href='#' class='dropdown-menu-link'>
              ${this.avatarTemplate(project)}
              <div class="align-middle">${_.escape(project.name)}</div>
            </a>
          </li>
        `;
    },
    avatarTemplate(project) {
      const identiconSizeClass = 's16 rect-avatar d-flex justify-content-center flex-column';
      return project.avatar_url
        ? renderAvatar(project, { sizeClass: 's16 rect-avatar' })
        : renderIdenticon(project, {
            sizeClass: identiconSizeClass,
          });
    },
  },
};
</script>

<template>
  <div>
    <div ref="projectsDropdown" class="dropdown dropdown-projects">
      <gl-button
        class="dropdown-menu-toggle wide shadow-none bg-white"
        type="button"
        data-toggle="dropdown"
        aria-expanded="false"
        :aria-label="label"
      >
        <gl-avatar
          v-if="isOnlyOneProjectSelected"
          :src="selectedProjects[0].avatar_url"
          :entity-id="selectedProjects[0].id"
          :entity-name="selectedProjects[0].name"
          :size="16"
          shape="rect"
          :alt="selectedProjects[0].name"
          class="d-inline-flex align-text-bottom"
        />
        {{ selectedProjectsLabel }}
        <icon name="chevron-down" />
      </gl-button>
      <div class="dropdown-menu dropdown-menu-selectable dropdown-menu-full-width">
        <div class="dropdown-title">{{ __('Projects') }}</div>
        <div class="dropdown-input">
          <input class="dropdown-input-field" type="search" :placeholder="__('Search projects')" />
          <icon name="search" class="dropdown-input-search" data-hidden="true" />
        </div>
        <div class="dropdown-content"></div>
        <gl-loading-icon class="dropdown-loading" />
      </div>
    </div>
  </div>
</template>
