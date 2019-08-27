<script>
import { s__, __ } from '~/locale';
import $ from 'jquery';
import _ from 'lodash-es';
import Icon from '~/vue_shared/components/icon.vue';
import { GlLoadingIcon, GlButton, GlAvatar } from '@gitlab/ui';
import Api from '~/api';
import { renderAvatar, renderIdenticon } from '~/helpers/avatar_helper';

export default {
  name: 'GroupsDropdownFilter',
  components: {
    Icon,
    GlLoadingIcon,
    GlButton,
    GlAvatar,
  },
  props: {
    label: {
      type: String,
      required: false,
      default: s__('CycleAnalytics|group dropdown filter'),
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
      selectedGroup: {},
    };
  },
  computed: {
    selectedGroupName() {
      return this.selectedGroup.name || __('Choose a group');
    },
  },
  mounted() {
    $(this.$refs.groupsDropdown).glDropdown({
      selectable: true,
      filterable: true,
      filterRemote: true,
      fieldName: 'group_id',
      search: {
        fields: ['full_name'],
      },
      clicked: this.onClick.bind(this),
      data: this.fetchData.bind(this),
      renderRow: group => this.rowTemplate(group),
      text: group => group.name,
      opened: e => e.target.querySelector('.dropdown-input-field').focus(),
    });
  },
  methods: {
    onClick({ selectedObj, e }) {
      e.preventDefault();
      this.selectedGroup = selectedObj;
      this.$emit('selected', this.selectedGroup);
    },
    fetchData(term, callback) {
      this.loading = true;

      return Api.groups(term, this.queryParams, groups => {
        this.loading = false;
        callback(groups);
      });
    },
    rowTemplate(group) {
      return `
            <li>
              <a href='#' class='dropdown-menu-link d-flex'>
                ${this.avatarTemplate(group)}
                <div class="js-group-path align-middle">${this.formatGroupPath(
                  group.full_name,
                )}</div>
              </a>
            </li>
          `;
    },
    /**
     * Formats the group's full name.
     * It renders the last part (the part after the last backslash) of a group's full name as bold text.
     * @returns String
     */
    formatGroupPath(fullName) {
      if (!fullName) {
        return '';
      }

      const parts = fullName.split('/');
      const lastPart = parts.length - 1;
      return parts
        .map((part, idx) =>
          idx === lastPart ? `<strong>${_.escape(part.trim())}</strong>` : _.escape(part.trim()),
        )
        .join(' / ');
    },
    avatarTemplate(group) {
      return group.avatar_url !== null
        ? renderAvatar(group, { sizeClass: 's16 rect-avatar flex-shrink-0' })
        : renderIdenticon(group, {
            sizeClass: 's16 rect-avatar d-flex justify-content-center flex-column flex-shrink-0',
          });
    },
  },
};
</script>

<template>
  <div>
    <div ref="groupsDropdown" class="dropdown dropdown-groups">
      <gl-button
        class="dropdown-menu-toggle wide shadow-none bg-white"
        type="button"
        data-toggle="dropdown"
        aria-expanded="false"
        :aria-label="label"
      >
        <gl-avatar
          v-if="selectedGroup.name"
          :src="selectedGroup.avatar_url"
          :entity-id="selectedGroup.id"
          :entity-name="selectedGroup.name"
          :size="16"
          shape="rect"
          :alt="selectedGroup.name"
          class="d-inline-flex align-text-bottom"
        />
        {{ selectedGroupName }}
        <icon name="chevron-down" />
      </gl-button>
      <div class="dropdown-menu dropdown-menu-selectable dropdown-menu-full-width">
        <div class="dropdown-title">{{ __('Groups') }}</div>
        <div class="dropdown-input">
          <input class="dropdown-input-field" type="search" :placeholder="__('Search groups')" />
          <icon name="search" class="dropdown-input-search" data-hidden="true" />
        </div>
        <div class="dropdown-content"></div>
        <gl-loading-icon class="dropdown-loading" />
      </div>
    </div>
  </div>
</template>
