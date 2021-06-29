<script>
import { mapActions, mapGetters } from 'vuex';
import BoardNewItem from '~/boards/components/board_new_item.vue';
import { toggleFormEventPrefix } from '~/boards/constants';
import eventHub from '~/boards/eventhub';

import { fullEpicBoardId } from '../boards_util';

export default {
  components: {
    BoardNewItem,
  },
  inject: ['boardId'],
  props: {
    list: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['isGroupBoard']),
    formEventPrefix() {
      return toggleFormEventPrefix.epic;
    },
  },
  methods: {
    ...mapActions(['addListNewEpic']),
    submit({ title }) {
      return this.addListNewEpic({
        epicInput: {
          title,
          boardId: fullEpicBoardId(this.boardId),
          listId: this.list.id,
        },
        list: this.list,
      }).then(() => {
        this.cancel();
      });
    },
    cancel() {
      eventHub.$emit(`${this.formEventPrefix}${this.list.id}`);
    },
  },
};
</script>

<template>
  <board-new-item
    :list="list"
    :form-event-prefix="formEventPrefix"
    :submit-button-title="__('Create epic')"
    @form-submit="submit"
    @form-cancel="cancel"
  />
</template>
