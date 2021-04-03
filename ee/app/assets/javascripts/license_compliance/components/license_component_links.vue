<script>
import { GlLink, GlIntersperse, GlModal, GlButton, GlModalDirective } from '@gitlab/ui';
import { uniqueId } from 'lodash';
import { sprintf, s__ } from '~/locale';

const MODAL_ID_PREFIX = 'license-component-link-modal-';
export const VISIBLE_COMPONENT_COUNT = 2;

export default {
  components: {
    GlIntersperse,
    GlLink,
    GlButton,
    GlModal,
  },
  directives: {
    GlModalDirective,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    components: {
      type: Array,
      required: true,
    },
  },
  computed: {
    modalId() {
      return uniqueId(MODAL_ID_PREFIX);
    },
    visibleComponents() {
      return this.components.slice(0, VISIBLE_COMPONENT_COUNT);
    },
    remainingComponentsCount() {
      return Math.max(0, this.components.length - VISIBLE_COMPONENT_COUNT);
    },
    hasComponentsInModal() {
      return this.remainingComponentsCount > 0;
    },
    lastSeparator() {
      return ` ${s__('SeriesFinalConjunction|and')} `;
    },
    modalButtonText() {
      const { remainingComponentsCount } = this;
      return sprintf(s__('Licenses|%{remainingComponentsCount} more'), {
        remainingComponentsCount,
      });
    },
    modalActionText() {
      return s__('Modal|Close');
    },
  },
  methods: {
    getComponentLabel({ name, version }) {
      return version ? `${name} (${version})` : name;
    },
  },
};
</script>

<template>
  <div>
    <gl-intersperse :last-separator="lastSeparator" class="js-component-links-component-list">
      <span
        v-for="(component, index) in visibleComponents"
        :key="index"
        class="js-component-links-component-list-item"
      >
        <gl-link v-if="component.blob_path" :href="component.blob_path" target="_blank">{{
          getComponentLabel(component)
        }}</gl-link>
        <template v-else>{{ getComponentLabel(component) }}</template>
      </span>
      <gl-button
        v-if="hasComponentsInModal"
        v-gl-modal-directive="modalId"
        variant="link"
        class="align-baseline js-component-links-modal-trigger"
      >
        {{ modalButtonText }}
      </gl-button>
    </gl-intersperse>
    <gl-modal
      v-if="hasComponentsInModal"
      :title="title"
      :modal-id="modalId"
      :ok-title="modalActionText"
      ok-only
      ok-variant="secondary"
    >
      <h5>{{ s__('Licenses|Components') }}</h5>
      <ul class="list-unstyled overflow-auto mh-50vh">
        <li
          v-for="component in components"
          :key="component.name"
          class="js-component-links-modal-item"
        >
          <gl-link v-if="component.blob_path" :href="component.blob_path" target="_blank">{{
            component.name
          }}</gl-link>
          <span v-else>{{ component.name }}</span>
        </li>
      </ul>
    </gl-modal>
  </div>
</template>
