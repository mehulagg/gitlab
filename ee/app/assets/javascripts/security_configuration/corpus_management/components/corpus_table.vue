<script>
import { GlTable } from '@gitlab/ui';
import actions from 'ee/security_configuration/corpus_management/components/columns/actions.vue';
import Date from 'ee/security_configuration/corpus_management/components/columns/date.vue';
import Name from 'ee/security_configuration/corpus_management/components/columns/name.vue';
import Target from 'ee/security_configuration/corpus_management/components/columns/target.vue';
import { __ } from '~/locale';
import deleteCorpus from '../graphql/mutations/delete_corpus.mutation.graphql';

const css = {
  thClass: 'gl-bg-transparent! gl-border-gray-100! gl-border-b-solid! gl-border-b-1!',
};

export default {
  components: {
    GlTable,
    Name,
    Target,
    Date,
    actions,
  },
  props: {
    corpuses: {
      type: Array,
      required: true,
    },
    projectFullPath: {
      type: String,
      required: true,
    },
  },
  fields: [
    {
      key: 'name',
      label: __('Corpus name'),
      thClass: css.thClass,
    },
    {
      key: 'target',
      label: __('Target'),
      thClass: css.thClass,
    },
    {
      key: 'lastUpdated',
      label: __('Last updated'),
      thClass: css.thClass,
    },
    {
      key: 'lastUsed',
      label: __('Last used'),
      thClass: css.thClass,
    },
    {
      key: 'actions',
      label: __('Actions'),
      thClass: css.thClass,
    },
  ],
  methods: {
    onDelete({ name }) {
      this.$apollo.mutate({
        mutation: deleteCorpus,
        variables: { name, projectPath: this.projectFullPath },
      });
    },
  },
};
</script>
<template>
  <gl-table :items="corpuses" :fields="$options.fields">
    <template #cell(name)="{ item }">
      <name :corpus="item" />
    </template>

    <template #cell(target)="{ item }">
      <target :target="item.target" />
    </template>

    <template #cell(lastUpdated)="{ item }">
      <date :date="item.lastUpdated" />
    </template>

    <template #cell(lastUsed)="{ item }">
      <date :date="item.lastUsed" />
    </template>

    <template #cell(actions)="{ item }">
      <actions :corpus="item" @delete="onDelete" />
    </template>
  </gl-table>
</template>
