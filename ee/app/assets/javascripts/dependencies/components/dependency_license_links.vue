<script>
import {
  GlButton,
  GlLink,
  GlModal,
  GlModalDirective,
  GlIntersperse,
  GlFriendlyWrap,
} from '@gitlab/ui';
import { uniqueId } from 'lodash';

import { sprintf, s__ } from '~/locale';

// If there are more licenses than this count, a counter will be displayed for the remaining licenses
// eg.: VISIBLE_LICENSE_COUNT = 2; licenses = ['MIT', 'GNU', 'GPL'] -> 'MIT, GNU and 1 more'
const VISIBLE_LICENSES_COUNT = 2;
const MODAL_ID_PREFIX = 'dependency-license-link-modal-';

export default {
  components: {
    GlIntersperse,
    GlButton,
    GlLink,
    GlModal,
    GlFriendlyWrap,
  },
  directives: {
    GlModalDirective,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    licenses: {
      type: Array,
      required: true,
    },
  },
  computed: {
    allLicenses() {
      return Array.isArray(this.licenses) ? this.licenses : [];
    },
    visibleLicenses() {
      return this.allLicenses.slice(0, VISIBLE_LICENSES_COUNT);
    },
    remainingLicensesCount() {
      return this.allLicenses.length - VISIBLE_LICENSES_COUNT;
    },
    hasLicensesInModal() {
      return this.remainingLicensesCount > 0;
    },
    lastSeparator() {
      return ` ${s__('SeriesFinalConjunction|and')} `;
    },
    modalId() {
      return uniqueId(MODAL_ID_PREFIX);
    },
    modalActionText() {
      return s__('Modal|Close');
    },
    modalButtonText() {
      const { remainingLicensesCount } = this;
      return sprintf(s__('Dependencies|%{remainingLicensesCount} more'), {
        remainingLicensesCount,
      });
    },
  },
};
</script>

<template>
  <div>
    <gl-intersperse :last-separator="lastSeparator" class="js-license-links-license-list">
      <span
        v-for="license in visibleLicenses"
        :key="license.name"
        class="js-license-links-license-list-item"
      >
        <gl-link v-if="license.url" :href="license.url" target="_blank">{{ license.name }}</gl-link>
        <gl-friendly-wrap v-else :text="license.name" />
      </span>
      <gl-button
        v-if="hasLicensesInModal"
        v-gl-modal-directive="modalId"
        variant="link"
        class="align-baseline js-license-links-modal-trigger"
        >{{ modalButtonText }}</gl-button
      >
    </gl-intersperse>
    <div class="js-license-links-modal">
      <gl-modal
        v-if="hasLicensesInModal"
        :title="title"
        :modal-id="modalId"
        :ok-title="modalActionText"
        ok-only
        ok-variant="secondary"
      >
        <h5>{{ __('Licenses') }}</h5>
        <ul class="list-unstyled">
          <li v-for="license in licenses" :key="license.name" class="js-license-links-modal-item">
            <gl-link v-if="license.url" :href="license.url" target="_blank">{{
              license.name
            }}</gl-link>
            <span v-else>{{ license.name }}</span>
          </li>
        </ul>
      </gl-modal>
    </div>
  </div>
</template>
