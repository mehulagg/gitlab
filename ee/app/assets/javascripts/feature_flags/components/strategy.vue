<script>
import Vue from 'vue';
import { isNumber } from 'lodash';
import {
  GlFormSelect,
  GlFormInput,
  GlFormTextarea,
  GlFormGroup,
  GlToken,
  GlDeprecatedButton,
  GlIcon,
} from '@gitlab/ui';
import { s__, __ } from '~/locale';
import {
  PERCENT_ROLLOUT_GROUP_ID,
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  ROLLOUT_STRATEGY_GITLAB_USER_LIST,
} from '../constants';

import NewEnvironmentsDropdown from './new_environments_dropdown.vue';

export default {
  components: {
    GlFormGroup,
    GlFormInput,
    GlFormTextarea,
    GlFormSelect,
    GlToken,
    GlDeprecatedButton,
    GlIcon,
    NewEnvironmentsDropdown,
  },
  model: {
    prop: 'strategy',
    event: 'change',
  },
  props: {
    strategy: {
      type: Object,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    endpoint: {
      type: String,
      required: false,
      default: '',
    },
    userLists: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  ROLLOUT_STRATEGY_ALL_USERS,
  ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
  ROLLOUT_STRATEGY_USER_ID,
  ROLLOUT_STRATEGY_GITLAB_USER_LIST,

  translations: {
    allEnvironments: __('All environments'),
    environmentsLabel: __('Environments'),
    removeLabel: s__('FeatureFlag|Delete strategy'),
    rolloutPercentageDescription: __('Enter a whole number between 0 and 100'),
    rolloutPercentageInvalid: s__(
      'FeatureFlags|Percent rollout must be a whole number between 0 and 100',
    ),
    rolloutPercentageLabel: s__('FeatureFlag|Percentage'),
    rolloutUserIdsDescription: __('Enter one or more user ID separated by commas'),
    rolloutUserIdsLabel: s__('FeatureFlag|User IDs'),
    rolloutUserListLabel: s__('FeatureFlag|List'),
    rolloutUserListDescription: s__('FeatureFlag|Select a user list'),
    rolloutUserListNoListError: s__('FeatureFlag|There are no configured user lists'),
    strategyTypeDescription: __('Select strategy activation method'),
    strategyTypeLabel: s__('FeatureFlag|Type'),
  },

  data() {
    return {
      environments: this.strategy.scopes || [],
      formStrategy: { ...this.strategy },
      formPercentage:
        this.strategy.name === ROLLOUT_STRATEGY_PERCENT_ROLLOUT
          ? this.strategy.parameters.percentage
          : '',
      formUserIds:
        this.strategy.name === ROLLOUT_STRATEGY_USER_ID ? this.strategy.parameters.userIds : '',
      formUserListId:
        this.strategy.name === ROLLOUT_STRATEGY_GITLAB_USER_LIST ? this.strategy.userListId : '',
      strategies: [
        {
          value: ROLLOUT_STRATEGY_ALL_USERS,
          text: __('All users'),
        },
        {
          value: ROLLOUT_STRATEGY_PERCENT_ROLLOUT,
          text: __('Percent of users'),
        },
        {
          value: ROLLOUT_STRATEGY_USER_ID,
          text: __('User IDs'),
        },
        {
          value: ROLLOUT_STRATEGY_GITLAB_USER_LIST,
          text: __('User List'),
        },
      ],
    };
  },
  computed: {
    strategyTypeId() {
      return `strategy-type-${this.index}`;
    },
    strategyPercentageId() {
      return `strategy-percentage-${this.index}`;
    },
    strategyUserIdsId() {
      return `strategy-user-ids-${this.index}`;
    },
    strategyUserListId() {
      return `strategy-user-list-${this.index}`;
    },
    environmentsDropdownId() {
      return `environments-dropdown-${this.index}`;
    },
    isPercentRollout() {
      return this.isStrategyType(ROLLOUT_STRATEGY_PERCENT_ROLLOUT);
    },
    isUserWithId() {
      return this.isStrategyType(ROLLOUT_STRATEGY_USER_ID);
    },
    isUserList() {
      return this.isStrategyType(ROLLOUT_STRATEGY_GITLAB_USER_LIST);
    },
    appliesToAllEnvironments() {
      return (
        this.filteredEnvironments.length === 0 ||
        (this.filteredEnvironments.length === 1 &&
          this.filteredEnvironments[0].environmentScope === '*')
      );
    },
    filteredEnvironments() {
      return this.environments.filter(e => !e.shouldBeDestroyed);
    },
    userListOptions() {
      return this.userLists.map(({ name, id }) => ({ value: id, text: name }));
    },
    hasUserLists() {
      return this.userListOptions.length > 0;
    },
  },
  methods: {
    addEnvironment(environment) {
      const allEnvironmentsScope = this.environments.find(scope => scope.environmentScope === '*');
      if (allEnvironmentsScope) {
        allEnvironmentsScope.shouldBeDestroyed = true;
      }
      this.environments.push({ environmentScope: environment });
      this.onStrategyChange();
    },
    onStrategyChange() {
      const parameters = {};
      const strategy = {
        ...this.formStrategy,
        scopes: this.environments,
      };
      switch (this.formStrategy.name) {
        case ROLLOUT_STRATEGY_PERCENT_ROLLOUT:
          parameters.percentage = this.formPercentage;
          parameters.groupId = PERCENT_ROLLOUT_GROUP_ID;
          break;
        case ROLLOUT_STRATEGY_USER_ID:
          parameters.userIds = this.formUserIds;
          break;
        case ROLLOUT_STRATEGY_GITLAB_USER_LIST:
          strategy.userListId = this.formUserListId;
          break;
        default:
          break;
      }
      this.$emit('change', {
        ...strategy,
        parameters,
      });
    },
    removeScope(environment) {
      if (isNumber(environment.id)) {
        Vue.set(environment, 'shouldBeDestroyed', true);
      } else {
        this.environments = this.environments.filter(e => e !== environment);
      }
      this.onStrategyChange();
    },
    isStrategyType(type) {
      return this.formStrategy.name === type;
    },
  },

  emits: ['change', 'delete'],
};
</script>
<template>
  <div class="border-top py-4">
    <div class="flex flex-column flex-md-row flex-md-wrap">
      <div class="mr-5">
        <gl-form-group
          :label="$options.translations.strategyTypeLabel"
          :description="$options.translations.strategyTypeDescription"
          :label-for="strategyTypeId"
        >
          <gl-form-select
            :id="strategyTypeId"
            v-model="formStrategy.name"
            :options="strategies"
            @change="onStrategyChange"
          />
        </gl-form-group>
      </div>

      <div data-testid="strategy">
        <gl-form-group
          v-if="isPercentRollout"
          :label="$options.translations.rolloutPercentageLabel"
          :description="$options.translations.rolloutPercentageDescription"
          :label-for="strategyPercentageId"
          :invalid-feedback="$options.translations.rolloutPercentageInvalid"
        >
          <div class="flex align-items-center">
            <gl-form-input
              :id="strategyPercentageId"
              v-model="formPercentage"
              class="rollout-percentage text-right w-3rem"
              type="number"
              @input="onStrategyChange"
            />
            <span class="ml-1">%</span>
          </div>
        </gl-form-group>

        <gl-form-group
          v-if="isUserWithId"
          :label="$options.translations.rolloutUserIdsLabel"
          :description="$options.translations.rolloutUserIdsDescription"
          :label-for="strategyUserIdsId"
        >
          <gl-form-textarea
            :id="strategyUserIdsId"
            v-model="formUserIds"
            @input="onStrategyChange"
          />
        </gl-form-group>
        <gl-form-group
          v-if="isUserList"
          :state="hasUserLists"
          :invalid-feedback="$options.translations.rolloutUserListNoListError"
          :label="$options.translations.rolloutUserListLabel"
          :description="$options.translations.rolloutUserListDescription"
          :label-for="strategyUserListId"
        >
          <gl-form-select
            :id="strategyUserListId"
            v-model="formUserListId"
            :options="userListOptions"
            @change="onStrategyChange"
          />
        </gl-form-group>
      </div>

      <div class="align-self-end align-self-md-stretch order-first offset-md-0 order-md-0 ml-auto">
        <gl-deprecated-button
          data-testid="delete-strategy-button"
          variant="danger"
          @click="$emit('delete')"
        >
          <span class="d-md-none">
            {{ $options.translations.removeLabel }}
          </span>
          <gl-icon class="d-none d-md-inline-flex" name="remove" />
        </gl-deprecated-button>
      </div>
    </div>
    <div class="flex flex-column">
      <label :for="environmentsDropdownId">{{ $options.translations.environmentsLabel }}</label>
      <div class="flex flex-column flex-md-row align-items-start align-items-md-center">
        <new-environments-dropdown
          :id="environmentsDropdownId"
          :endpoint="endpoint"
          class="mr-2"
          @add="addEnvironment"
        />
        <span v-if="appliesToAllEnvironments" class="text-secondary mt-2 mt-md-0 ml-md-3">
          {{ $options.translations.allEnvironments }}
        </span>
        <div v-else class="flex align-items-center">
          <gl-token
            v-for="environment in filteredEnvironments"
            :key="environment.id"
            class="mt-2 mr-2 mt-md-0 mr-md-0 ml-md-2 rounded-pill"
            @close="removeScope(environment)"
          >
            {{ environment.environmentScope }}
          </gl-token>
        </div>
      </div>
    </div>
  </div>
</template>
