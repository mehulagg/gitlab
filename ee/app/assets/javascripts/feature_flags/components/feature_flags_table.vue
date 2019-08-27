<script>
import _ from 'lodash-es';
import { GlButton, GlLink, GlTooltipDirective, GlModalDirective, GlModal } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import Icon from '~/vue_shared/components/icon.vue';
import { ROLLOUT_STRATEGY_PERCENT_ROLLOUT } from '../constants';

export default {
  components: {
    GlButton,
    GlLink,
    Icon,
    GlModal,
  },
  directives: {
    GlModalDirective,
    GlTooltip: GlTooltipDirective,
  },
  props: {
    csrfToken: {
      type: String,
      required: true,
    },
    featureFlags: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      deleteFeatureFlagUrl: null,
      deleteFeatureFlagName: null,
    };
  },
  computed: {
    permissions() {
      return gon && gon.features && gon.features.featureFlagPermissions;
    },
    modalTitle() {
      return sprintf(
        s__('FeatureFlags|Delete %{name}?'),
        {
          name: _.escape(this.deleteFeatureFlagName),
        },
        false,
      );
    },
    deleteModalMessage() {
      return sprintf(
        s__('FeatureFlags|Feature flag %{name} will be removed. Are you sure?'),
        {
          name: _.escape(this.deleteFeatureFlagName),
        },
        false,
      );
    },
    modalId() {
      return 'delete-feature-flag';
    },
  },
  methods: {
    scopeTooltipText(scope) {
      return !scope.active
        ? sprintf(s__('FeatureFlags|Inactive flag for %{scope}'), {
            scope: scope.environmentScope,
          })
        : '';
    },
    badgeText(scope) {
      const displayName =
        scope.environmentScope === '*'
          ? s__('FeatureFlags|* (All environments)')
          : scope.environmentScope;

      const displayPercentage =
        scope.rolloutStrategy === ROLLOUT_STRATEGY_PERCENT_ROLLOUT
          ? `: ${scope.rolloutPercentage}%`
          : '';

      return `${displayName}${displayPercentage}`;
    },
    canDeleteFlag(flag) {
      return !this.permissions || (flag.scopes || []).every(scope => scope.can_update);
    },
    setDeleteModalData(featureFlag) {
      this.deleteFeatureFlagUrl = featureFlag.destroy_path;
      this.deleteFeatureFlagName = featureFlag.name;
    },
    onSubmit() {
      this.$refs.form.submit();
    },
  },
};
</script>
<template>
  <div class="table-holder js-feature-flag-table">
    <div class="gl-responsive-table-row table-row-header" role="row">
      <div class="table-section section-10" role="columnheader">
        {{ s__('FeatureFlags|Status') }}
      </div>
      <div class="table-section section-20" role="columnheader">
        {{ s__('FeatureFlags|Feature Flag') }}
      </div>
      <div class="table-section section-50" role="columnheader">
        {{ s__('FeatureFlags|Environment Specs') }}
      </div>
    </div>

    <template v-for="featureFlag in featureFlags">
      <div :key="featureFlag.id" class="gl-responsive-table-row" role="row">
        <div class="table-section section-10" role="gridcell">
          <div class="table-mobile-header" role="rowheader">{{ s__('FeatureFlags|Status') }}</div>
          <div class="table-mobile-content js-feature-flag-status">
            <span v-if="featureFlag.active" class="badge badge-success">
              {{ s__('FeatureFlags|Active') }}
            </span>
            <span v-else class="badge badge-danger">{{ s__('FeatureFlags|Inactive') }}</span>
          </div>
        </div>

        <div class="table-section section-20" role="gridcell">
          <div class="table-mobile-header" role="rowheader">
            {{ s__('FeatureFlags|Feature Flag') }}
          </div>
          <div class="table-mobile-content d-flex flex-column js-feature-flag-title">
            <div class="feature-flag-name text-monospace text-truncate">{{ featureFlag.name }}</div>
            <div class="feature-flag-description text-secondary text-truncate">
              {{ featureFlag.description }}
            </div>
          </div>
        </div>

        <div class="table-section section-50" role="gridcell">
          <div class="table-mobile-header" role="rowheader">
            {{ s__('FeatureFlags|Environment Specs') }}
          </div>
          <div
            class="table-mobile-content d-flex flex-wrap justify-content-end justify-content-md-start js-feature-flag-environments"
          >
            <span
              v-for="scope in featureFlag.scopes"
              :key="scope.id"
              v-gl-tooltip.hover="scopeTooltipText(scope)"
              class="badge append-right-8 prepend-top-2"
              :class="{
                'badge-active': scope.active,
                'badge-inactive': !scope.active,
              }"
              >{{ badgeText(scope) }}</span
            >
          </div>
        </div>

        <div class="table-section section-20 table-button-footer" role="gridcell">
          <div class="table-action-buttons btn-group">
            <template v-if="featureFlag.edit_path">
              <gl-button
                v-gl-tooltip.hover.bottom="__('Edit')"
                class="js-feature-flag-edit-button"
                variant="outline-primary"
                :href="featureFlag.edit_path"
              >
                <icon name="pencil" :size="16" />
              </gl-button>
            </template>
            <template v-if="featureFlag.destroy_path">
              <gl-button
                v-gl-tooltip.hover.bottom="__('Delete')"
                v-gl-modal-directive="modalId"
                class="js-feature-flag-delete-button"
                variant="danger"
                :disabled="!canDeleteFlag(featureFlag)"
                @click="setDeleteModalData(featureFlag)"
              >
                <icon name="remove" :size="16" />
              </gl-button>
            </template>
          </div>
        </div>
      </div>
    </template>

    <gl-modal
      :title="modalTitle"
      :ok-title="s__('FeatureFlags|Delete feature flag')"
      :modal-id="modalId"
      title-tag="h4"
      ok-variant="danger"
      @ok="onSubmit"
    >
      {{ deleteModalMessage }}
      <form ref="form" :action="deleteFeatureFlagUrl" method="post" class="js-requires-input">
        <input ref="method" type="hidden" name="_method" value="delete" />
        <input :value="csrfToken" type="hidden" name="authenticity_token" />
      </form>
    </gl-modal>
  </div>
</template>
