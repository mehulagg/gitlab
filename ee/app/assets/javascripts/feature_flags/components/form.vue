<script>
import Vue from 'vue';
import _ from 'lodash-es';
import { GlButton, GlBadge, GlTooltip, GlTooltipDirective } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import ToggleButton from '~/vue_shared/components/toggle_button.vue';
import Icon from '~/vue_shared/components/icon.vue';
import EnvironmentsDropdown from './environments_dropdown.vue';
import {
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ALL_ENVIRONMENTS_NAME,
  INTERNAL_ID_PREFIX,
} from '../constants';
import { createNewEnvironmentScope } from '../store/modules/helpers';
import UserWithId from './strategies/user_with_id.vue';

export default {
  components: {
    GlButton,
    GlBadge,
    GlTooltip,
    ToggleButton,
    Icon,
    EnvironmentsDropdown,
    UserWithId,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    name: {
      type: String,
      required: false,
      default: '',
    },
    description: {
      type: String,
      required: false,
      default: '',
    },
    scopes: {
      type: Array,
      required: false,
      default: () => [],
    },
    cancelPath: {
      type: String,
      required: true,
    },
    submitText: {
      type: String,
      required: true,
    },
    environmentsEndpoint: {
      type: String,
      required: true,
    },
  },

  allEnvironmentsText: s__('FeatureFlags|* (All Environments)'),

  helpText: sprintf(
    s__(
      'FeatureFlags|Feature Flag behavior is built up by creating a set of rules to define the status of target environments. A default wildcard rule %{codeStart}*%{codeEnd} for %{boldStart}All Environments%{boldEnd} is set, and you are able to add as many rules as you need by choosing environment specs below. You can toggle the behavior for each of your rules to set them %{boldStart}Active%{boldEnd} or %{boldStart}Inactive%{boldEnd}.',
    ),
    {
      codeStart: '<code>',
      codeEnd: '</code>',
      boldStart: '<b>',
      boldEnd: '</b>',
    },
    false,
  ),

  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,

  // Matches numbers 0 through 100
  rolloutPercentageRegex: /^[0-9]$|^[1-9][0-9]$|^100$/,

  data() {
    return {
      formName: this.name,
      formDescription: this.description,

      // operate on a clone to avoid mutating props
      formScopes: this.scopes.map(s => ({ ...s })),

      newScope: '',
    };
  },
  computed: {
    filteredScopes() {
      return this.formScopes.filter(scope => !scope.shouldBeDestroyed);
    },
    canUpdateFlag() {
      return !this.permissionsFlag || (this.formScopes || []).every(scope => scope.canUpdate);
    },
    permissionsFlag() {
      return gon && gon.features && gon.features.featureFlagPermissions;
    },

    userIds() {
      const scope = this.formScopes.find(s => Array.isArray(s.rolloutUserIds)) || {};
      return scope.rolloutUserIds || [];
    },
  },
  methods: {
    isAllEnvironment(name) {
      return name === ALL_ENVIRONMENTS_NAME;
    },

    /**
     * When the user clicks the remove button we delete the scope
     *
     * If the scope has an ID, we need to add the `shouldBeDestroyed` flag.
     * If the scope does *not* have an ID, we can just remove it.
     *
     * This flag will be used when submitting the data to the backend
     * to determine which records to delete (via a "_destroy" property).
     *
     * @param {Object} scope
     */
    removeScope(scope) {
      if (_.isString(scope.id) && scope.id.startsWith(INTERNAL_ID_PREFIX)) {
        this.formScopes = this.formScopes.filter(s => s !== scope);
      } else {
        Vue.set(scope, 'shouldBeDestroyed', true);
      }
    },

    /**
     * Creates a new scope and adds it to the list of scopes
     *
     * @param overrides An object whose properties will
     * be used override the default scope options
     */
    createNewScope(overrides) {
      this.formScopes.push(createNewEnvironmentScope(overrides));
      this.newScope = '';
    },

    /**
     * When the user clicks the submit button
     * it triggers an event with the form data
     */
    handleSubmit() {
      this.$emit('handleSubmit', {
        name: this.formName,
        description: this.formDescription,
        scopes: this.formScopes,
      });
    },

    updateUserIds(userIds) {
      this.formScopes = this.formScopes.map(s => ({
        ...s,
        rolloutUserIds: userIds,
      }));
    },

    canUpdateScope(scope) {
      return !this.permissionsFlag || scope.canUpdate;
    },

    isRolloutPercentageInvalid: _.memoize(function isRolloutPercentageInvalid(percentage) {
      return !this.$options.rolloutPercentageRegex.test(percentage);
    }),

    /**
     * Generates a unique ID for the strategy based on the v-for index
     *
     * @param index The index of the strategy
     */
    rolloutStrategyId(index) {
      return `rollout-strategy-${index}`;
    },

    /**
     * Generates a unique ID for the percentage based on the v-for index
     *
     * @param index The index of the percentage
     */
    rolloutPercentageId(index) {
      return `rollout-percentage-${index}`;
    },
  },
};
</script>
<template>
  <form class="feature-flags-form">
    <fieldset>
      <div class="row">
        <div class="form-group col-md-4">
          <label for="feature-flag-name" class="label-bold">{{ s__('FeatureFlags|Name') }} *</label>
          <input
            id="feature-flag-name"
            v-model="formName"
            :disabled="!canUpdateFlag"
            class="form-control"
          />
        </div>
      </div>

      <div class="row">
        <div class="form-group col-md-4">
          <label for="feature-flag-description" class="label-bold">
            {{ s__('FeatureFlags|Description') }}
          </label>
          <textarea
            id="feature-flag-description"
            v-model="formDescription"
            :disabled="!canUpdateFlag"
            class="form-control"
            rows="4"
          ></textarea>
        </div>
      </div>

      <div class="row">
        <div class="form-group col-md-12">
          <h4>{{ s__('FeatureFlags|Target environments') }}</h4>
          <div v-html="$options.helpText"></div>

          <div class="js-scopes-table prepend-top-default">
            <div class="gl-responsive-table-row table-row-header" role="row">
              <div class="table-section section-30" role="columnheader">
                {{ s__('FeatureFlags|Environment Spec') }}
              </div>
              <div class="table-section section-20 text-center" role="columnheader">
                {{ s__('FeatureFlags|Status') }}
              </div>
              <div class="table-section section-40" role="columnheader">
                {{ s__('FeatureFlags|Rollout Strategy') }}
              </div>
            </div>

            <div
              v-for="(scope, index) in filteredScopes"
              :key="scope.id"
              class="gl-responsive-table-row"
              role="row"
            >
              <div class="table-section section-30" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Environment Spec') }}
                </div>
                <div
                  class="table-mobile-content js-feature-flag-status d-flex align-items-center justify-content-start"
                >
                  <p v-if="isAllEnvironment(scope.environmentScope)" class="js-scope-all pl-3">
                    {{ $options.allEnvironmentsText }}
                  </p>

                  <environments-dropdown
                    v-else
                    class="col-12"
                    :value="scope.environmentScope"
                    :endpoint="environmentsEndpoint"
                    :disabled="!canUpdateScope(scope)"
                    @selectEnvironment="env => (scope.environmentScope = env)"
                    @createClicked="env => (scope.environmentScope = env)"
                    @clearInput="env => (scope.environmentScope = '')"
                  />

                  <gl-badge v-if="permissionsFlag && scope.protected" variant="success">{{
                    s__('FeatureFlags|Protected')
                  }}</gl-badge>
                </div>
              </div>

              <div class="table-section section-20 text-center" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Status') }}
                </div>
                <div class="table-mobile-content js-feature-flag-status">
                  <toggle-button
                    :value="scope.active"
                    :disabled-input="!canUpdateScope(scope)"
                    @change="status => (scope.active = status)"
                  />
                </div>
              </div>

              <div class="table-section section-40" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Rollout Strategy') }}
                </div>
                <div class="table-mobile-content js-rollout-strategy form-inline">
                  <label class="sr-only" :for="rolloutStrategyId(index)">
                    {{ s__('FeatureFlags|Rollout Strategy') }}
                  </label>
                  <div class="select-wrapper col-12 col-md-8 p-0">
                    <select
                      :id="rolloutStrategyId(index)"
                      v-model="scope.rolloutStrategy"
                      :disabled="!scope.active"
                      class="form-control select-control w-100 js-rollout-strategy"
                    >
                      <option :value="$options.ROLLOUT_STRATEGY_ALL_USERS">{{
                        s__('FeatureFlags|All users')
                      }}</option>
                      <option :value="$options.ROLLOUT_STRATEGY_PERCENT_ROLLOUT">{{
                        s__('FeatureFlags|Percent rollout (logged in users)')
                      }}</option>
                    </select>
                    <i aria-hidden="true" data-hidden="true" class="fa fa-chevron-down"></i>
                  </div>

                  <div
                    v-if="scope.rolloutStrategy === $options.ROLLOUT_STRATEGY_PERCENT_ROLLOUT"
                    class="d-flex-center mt-2 mt-md-0 ml-md-2"
                  >
                    <label class="sr-only" :for="rolloutPercentageId(index)">
                      {{ s__('FeatureFlags|Rollout Percentage') }}
                    </label>
                    <div class="w-3rem">
                      <input
                        :id="rolloutPercentageId(index)"
                        v-model="scope.rolloutPercentage"
                        :disabled="!scope.active"
                        :class="{
                          'is-invalid': isRolloutPercentageInvalid(scope.rolloutPercentage),
                        }"
                        type="number"
                        min="0"
                        max="100"
                        :pattern="$options.rolloutPercentageRegex.source"
                        class="rollout-percentage js-rollout-percentage form-control text-right w-100"
                      />
                    </div>
                    <gl-tooltip
                      v-if="isRolloutPercentageInvalid(scope.rolloutPercentage)"
                      :target="rolloutPercentageId(index)"
                    >
                      {{
                        s__('FeatureFlags|Percent rollout must be a whole number between 0 and 100')
                      }}
                    </gl-tooltip>
                    <span class="ml-1">%</span>
                  </div>
                </div>
              </div>

              <div class="table-section section-10 text-right" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Remove') }}
                </div>
                <div class="table-mobile-content js-feature-flag-delete">
                  <gl-button
                    v-if="!isAllEnvironment(scope.environmentScope) && canUpdateScope(scope)"
                    v-gl-tooltip
                    :title="s__('FeatureFlags|Remove')"
                    class="js-delete-scope btn-transparent pr-3 pl-3"
                    @click="removeScope(scope)"
                  >
                    <icon name="clear" />
                  </gl-button>
                </div>
              </div>
            </div>

            <div class="js-add-new-scope gl-responsive-table-row" role="row">
              <div class="table-section section-30" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Environment Spec') }}
                </div>
                <div class="table-mobile-content js-feature-flag-status">
                  <environments-dropdown
                    class="js-new-scope-name col-12"
                    :endpoint="environmentsEndpoint"
                    :value="newScope"
                    @selectEnvironment="env => createNewScope({ environmentScope: env })"
                    @createClicked="env => createNewScope({ environmentScope: env })"
                  />
                </div>
              </div>

              <div class="table-section section-20 text-center" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Status') }}
                </div>
                <div class="table-mobile-content js-feature-flag-status">
                  <toggle-button :value="false" @change="createNewScope({ active: true })" />
                </div>
              </div>

              <div class="table-section section-40" role="gridcell">
                <div class="table-mobile-header" role="rowheader">
                  {{ s__('FeatureFlags|Rollout Strategy') }}
                </div>
                <div class="table-mobile-content js-rollout-strategy form-inline">
                  <label class="sr-only" for="new-rollout-strategy-placeholder">
                    {{ s__('FeatureFlags|Rollout Strategy') }}
                  </label>
                  <div class="select-wrapper col-12 col-md-8 p-0">
                    <select
                      id="new-rollout-strategy-placeholder"
                      disabled
                      class="form-control select-control w-100"
                    >
                      <option>{{ s__('FeatureFlags|All users') }}</option>
                    </select>
                    <i aria-hidden="true" data-hidden="true" class="fa fa-chevron-down"></i>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </fieldset>
    <user-with-id :value="userIds" @input="updateUserIds" />

    <div class="form-actions">
      <gl-button
        ref="submitButton"
        type="button"
        variant="success"
        class="js-ff-submit col-xs-12"
        @click="handleSubmit"
      >
        {{ submitText }}
      </gl-button>
      <gl-button :href="cancelPath" variant="secondary" class="js-ff-cancel col-xs-12 float-right">
        {{ __('Cancel') }}
      </gl-button>
    </div>
  </form>
</template>
