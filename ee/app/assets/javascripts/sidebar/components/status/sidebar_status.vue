<script>
import { mapGetters } from 'vuex';
import createFlash from '~/flash';
import { __ } from '~/locale';
import { OPENED, REOPENED } from '~/notes/constants';
import Status from './status.vue';

export default {
  components: {
    Status,
  },
  props: {
    mediator: {
      required: true,
      type: Object,
      validator(mediatorObject) {
        return Boolean(mediatorObject.store);
      },
    },
  },
  computed: {
    ...mapGetters(['getNoteableData']),
    isOpen() {
      return this.getNoteableData.state === OPENED || this.getNoteableData.state === REOPENED;
    },
  },
  methods: {
    handleDropdownClick(status) {
      this.mediator.updateStatus(status).catch(() => {
        createFlash({
          message: __('Error occurred while updating the issue status'),
        });
      });
    },
  },
};
</script>

<template>
  <status
    :is-open="isOpen"
    :is-editable="mediator.store.editable"
    :is-fetching="mediator.store.isFetching.status"
    :status="mediator.store.status"
    @onDropdownClick="handleDropdownClick"
  />
</template>
