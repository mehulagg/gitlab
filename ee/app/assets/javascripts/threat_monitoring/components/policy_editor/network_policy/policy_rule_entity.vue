<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { sprintf, s__ } from '~/locale';
import { EntityTypes } from './lib';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  model: {
    prop: 'value',
    event: 'change',
  },
  props: {
    value: {
      type: Array,
      required: true,
    },
  },
  computed: {
    selectedEntities() {
      const { value } = this;

      if (value.length === 0) {
        return s__('NetworkPolicies|None selected');
      }

      if (value.includes(EntityTypes.ALL)) return s__('NetworkPolicies|All selected');

      if (value.length > 3) {
        return sprintf(s__('NetworkPolicies|%{number} selected'), { number: value.length });
      }

      return value.join(', ');
    },
  },
  methods: {
    selectEntity(entity) {
      const { value } = this;
      let entitiesList = [];
      if (value.includes(entity)) {
        entitiesList = value.filter((e) => e !== entity);
      } else {
        entitiesList = [...value, entity];
      }

      if (
        entitiesList.includes(EntityTypes.ALL) ||
        entitiesList.length === Object.keys(EntityTypes).length - 1
      ) {
        entitiesList = [EntityTypes.ALL];
      }

      this.$emit('change', entitiesList);
    },
    isSelectedEntity(entity) {
      const { value } = this;
      if (value.includes(EntityTypes.ALL)) return true;

      return value.includes(entity);
    },
  },
  entities: Object.keys(EntityTypes).map((type) => ({
    value: EntityTypes[type],
    text: EntityTypes[type],
  })),
};
</script>

<template>
  <gl-dropdown :text="selectedEntities" multiple>
    <gl-dropdown-item
      v-for="entity in $options.entities"
      :key="entity.value"
      is-check-item
      :is-checked="isSelectedEntity(entity.value)"
      @click="selectEntity(entity.value)"
      >{{ entity.text }}</gl-dropdown-item
    >
  </gl-dropdown>
</template>
