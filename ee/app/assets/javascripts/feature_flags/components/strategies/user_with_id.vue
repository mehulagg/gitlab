<script>
import _ from 'lodash-es';
import { GlFormGroup, GlFormInput, GlBadge, GlButton } from '@gitlab/ui';
import Icon from '~/vue_shared/components/icon.vue';
import { sprintf, s__ } from '~/locale';

export default {
  targetUsersHeader: s__('FeatureFlags|Target Users'),
  userIdLabel: s__('FeatureFlags|User IDs'),
  userIdHelp: s__('FeatureFlags|Enter comma separated list of user IDs'),
  addButtonLabel: s__('FeatureFlags|Add'),
  clearAllButtonLabel: s__('FeatureFlags|Clear all'),
  targetUsersHtml: sprintf(
    s__(
      'FeatureFlags|Target user behaviour is built up by creating a list of active user IDs. These IDs should be the users in the system in which the feature flag is set, not GitLab ids. Target users apply across %{strong_start}All Environments%{strong_end} and are not affected by Target Environment rules.',
    ),
    {
      strong_start: '<strong>',
      strong_end: '</strong>',
    },
    false,
  ),

  components: {
    GlFormGroup,
    GlFormInput,
    GlBadge,
    GlButton,
    Icon,
  },
  props: {
    value: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      userId: '',
    };
  },
  computed: {},
  methods: {
    /**
     * @description Given a comma-separated list of IDs, append it to current
     *  list of user IDs. IDs are only added if they are new, i.e., the list
     *  contains only unique IDs, and those IDs must also be a truthy value,
     *  i.e., they cannot be empty strings. The result is then emitted to
     *  parent component via the 'input' event.
     * @param {string} value - A list of user IDs comma-separated ("1,2,3")
     */
    updateUserIds(value = this.userId) {
      this.userId = '';
      this.$emit(
        'input',
        _.uniq([
          ...this.value,
          ...value
            .split(',')
            .filter(x => x)
            .map(x => x.trim()),
        ]),
      );
    },
    /**
     * @description Removes the given ID from the current list of IDs. and
     *  emits the result via the `input` event.
     * @param {string} id - The ID to remove.
     */
    removeUser(id) {
      this.$emit('input', this.value.filter(i => i !== id));
    },
    /**
     * @description Clears both the user ID list via the 'input' event as well
     *  as the value of the comma-separated list
     */
    clearAll() {
      this.$emit('input', []);
      this.userId = '';
    },
    /**
     * @description Updates the list of user IDs with those in the
     *  comma-separated list.
     * @see {@link updateUserIds}
     */
    onClickAdd() {
      this.updateUserIds(this.userId);
    },
  },
};
</script>
<template>
  <fieldset class="mb-5">
    <h4>{{ $options.targetUsersHeader }}</h4>
    <p v-html="$options.targetUsersHtml"></p>
    <gl-form-group
      :label="$options.userIdLabel"
      :description="$options.userIdHelp"
      label-for="userId"
    >
      <div class="d-flex">
        <gl-form-input
          id="userId"
          v-model="userId"
          class="col-md-4 mr-2"
          @keyup.enter.native="updateUserIds()"
        />
        <gl-button variant="success" class="btn-inverted mr-1" @click="onClickAdd">
          {{ $options.addButtonLabel }}
        </gl-button>
        <gl-button variant="danger" class="btn btn-inverted" @click="clearAll">
          {{ $options.clearAllButtonLabel }}
        </gl-button>
      </div>
    </gl-form-group>
    <div class="d-flex flex-wrap">
      <gl-badge v-for="id in value" :key="id" :pill="true" class="m-1 d-flex align-items-center">
        <p class="ws-normal m-1 text-break text-left">{{ id }}</p>
        <span @click="removeUser(id)"><icon name="close"/></span>
      </gl-badge>
    </div>
  </fieldset>
</template>
