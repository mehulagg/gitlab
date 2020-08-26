<script>
import FormInput from './form_input.vue';
import { isValidConfigurationEntity } from './utils';

export default {
  components: {
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
      validator: value => value.every(isValidConfigurationEntity),
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
  },

  emits: ['input'],
};
</script>

<template>
  <div>
    <component
      :is="componentForEntity(entity)"
      v-for="entity in entities"
      ref="fields"
      :key="entity.field"
      v-bind="entity"
      @input="onInput(entity.field, $event)"
    />
  </div>
</template>
