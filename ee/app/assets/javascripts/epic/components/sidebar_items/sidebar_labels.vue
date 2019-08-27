<script>
import { mapState, mapActions } from 'vuex';
import _ from 'lodash-es';

import ListLabel from '../../models/label';

import LabelsSelect from '~/vue_shared/components/sidebar/labels_select/base.vue';

export default {
  components: {
    LabelsSelect,
  },
  props: {
    canUpdate: {
      type: Boolean,
      required: true,
    },
    sidebarCollapsed: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      sidebarExpandedOnClick: false,
    };
  },
  computed: {
    ...mapState([
      'labels',
      'namespace',
      'updateEndpoint',
      'labelsPath',
      'labelsWebUrl',
      'epicsWebUrl',
      'scopedLabels',
      'scopedLabelsDocumentationLink',
    ]),
    epicContext() {
      return {
        labels: this.labels,
      };
    },
  },
  mounted() {
    document.addEventListener(
      'toggleSidebarRevealLabelsDropdown',
      this.toggleSidebarRevealLabelsDropdown,
    );
  },
  beforeDestroy() {
    document.removeEventListener(
      'toggleSidebarRevealLabelsDropdown',
      this.toggleSidebarRevealLabelsDropdown,
    );
  },
  methods: {
    ...mapActions(['toggleSidebar']),
    toggleSidebarRevealLabelsDropdown() {
      const contentContainer = this.$el.closest('.page-with-contextual-sidebar');
      this.toggleSidebar({ sidebarCollapsed: this.sidebarCollapsed });
      // When sidebar is expanded, we need to wait
      // for rendering to finish before opening
      // dropdown as otherwise it causes `calc()`
      // used in CSS to miscalculate collapsed
      // sidebar size.
      _.debounce(() => {
        this.sidebarExpandedOnClick = true;
        if (contentContainer) {
          contentContainer
            .querySelector('.js-sidebar-dropdown-toggle')
            .dispatchEvent(new Event('click', { bubbles: true, cancelable: false }));
        }
      }, 100)();
    },
    handleDropdownClose() {
      if (this.sidebarExpandedOnClick) {
        this.sidebarExpandedOnClick = false;
        this.toggleSidebar({ sidebarCollapsed: this.sidebarCollapsed });
      }
    },
    handleLabelClick(label) {
      if (label.isAny) {
        this.epicContext.labels = [];
      } else {
        const labelIndex = this.epicContext.labels.findIndex(l => l.id === label.id);

        if (labelIndex === -1) {
          this.epicContext.labels.push(
            new ListLabel({
              id: label.id,
              title: label.title,
              color: label.color[0],
              textColor: label.text_color,
            }),
          );
        } else {
          this.epicContext.labels.splice(labelIndex, 1);
        }
      }
    },
  },
};
</script>

<template>
  <labels-select
    :can-edit="canUpdate"
    :context="epicContext"
    :namespace="namespace"
    :update-path="updateEndpoint"
    :labels-path="labelsPath"
    :labels-web-url="labelsWebUrl"
    :label-filter-base-path="epicsWebUrl"
    :show-create="true"
    :enable-scoped-labels="scopedLabels"
    :scoped-labels-documentation-link="scopedLabelsDocumentationLink"
    ability-name="epic"
    @onLabelClick="handleLabelClick"
    @onDropdownClose="handleDropdownClose"
    @toggleCollapse="toggleSidebarRevealLabelsDropdown"
    >{{ __('None') }}</labels-select
  >
</template>
