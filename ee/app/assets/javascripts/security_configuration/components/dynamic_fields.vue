<script>
import { GlFormGroup } from '@gitlab/ui';
import DropdownInput from './dropdown_input.vue';
import FormInput from './form_input.vue';
import { isValidConfigurationEntity } from './utils';

export default {
  components: {
    GlFormGroup,
    FormInput,
  },
  model: {
    prop: 'entities',
    event: 'input',
  },
  props: {
    entities: {
      type: Array,
      required: true,
      validator: (value) => value.every(isValidConfigurationEntity),
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    componentForEntity({ type }) {
      return this.$options.entityTypeToComponent[type];
    },
    onInput(fieldName, newValue) {
      const entityIndex = this.entities.findIndex(({ field }) => field === fieldName);

      const updatedEntity = {
        ...this.entities[entityIndex],
        value: newValue,
      };

      const newEntities = [...this.entities];
      newEntities.splice(entityIndex, 1, updatedEntity);

      this.$emit('input', newEntities);
    },
  },
  // Entities with types not listed here are not rendered, since Vue does not
  // render <component :is="undefined" />. This means that unsupported entities
  // are omitted silently, which is actually the *desirable* behaviour, as it
  // decouples the frontend from the backend: the backend may add new types
  // before the frontend adds support for them.
  entityTypeToComponent: {
    string: FormInput,
    select: DropdownInput,
  },
};
</script>

<template>
  <gl-form-group :disabled="disabled">
    <component
      :is="componentForEntity(entity)"
      v-for="entity in entities"
      ref="fields"
      :key="entity.field"
      :disabled="disabled"
      v-bind="entity"
      @input="onInput(entity.field, $event)"
    />
  </gl-form-group>
</template>
