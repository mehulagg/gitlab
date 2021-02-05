<script>
import DeleteUserModal from './delete_user_modal.vue';

export default {
  components: { DeleteUserModal },
  props: {
    modalConfiguration: {
      required: true,
      type: Object,
    },
    csrfToken: {
      required: true,
      type: String,
    },
    selector: {
      required: true,
      type: String,
    },
  },
  data() {
    return {
      currentModalData: null,
    };
  },
  computed: {
    activeModal() {
      return Boolean(this.currentModalData);
    },

    modalProps() {
      const { glModalAction: requestedAction } = this.currentModalData;
      return {
        ...this.modalConfiguration[requestedAction],
        ...this.currentModalData,
        csrfToken: this.csrfToken,
      };
    },
  },

  mounted() {
    document.querySelectorAll(this.selector).forEach((button) => {
      button.addEventListener('click', (e) => {
        if(!button.dataset.glModalAction) return;

        e.preventDefault();
        this.show(button.dataset);
      });
    });
  },

  methods: {
    show(modalData) {
      const { glModalAction: requestedAction } = modalData;

      if (!this.modalConfiguration[requestedAction]) {
        throw new Error(`Modal action ${requestedAction} has no configuration in HTML`);
      }

      this.currentModalData = modalData;

      return this.$nextTick().then(() => {
        this.$refs.modal.show();
      });
    },
  },
};
</script>
<template>
  <delete-user-modal v-if="activeModal" ref="modal" v-bind="modalProps" />
</template>
