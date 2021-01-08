<script>
import { GlModal } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { s__, sprintf } from '~/locale';
import { visitUrl } from '~/lib/utils/url_utility';

export default {
  components: {
    GlModal,
  },
  data() {
    return {
      milestoneTitle: '',
      url: '',
      groupName: '',
      currentButton: null,
      visible: false,
    };
  },
  computed: {
    title() {
      return sprintf(s__('Milestones|Promote %{milestoneTitle} to group milestone?'), {
        milestoneTitle: this.milestoneTitle,
      });
    },
    text() {
      return sprintf(
        s__(`Milestones|Promoting %{milestoneTitle} will make it available for all projects inside %{groupName}.
        Existing project milestones with the same title will be merged.`),
        { milestoneTitle: this.milestoneTitle, groupName: this.groupName },
      );
    },
  },
  mounted() {
    this.getButtons().forEach((button) => {
      button.addEventListener('click', this.onPromoteButtonClick);
      button.removeAttribute('disabled');
    });
  },
  beforeDestroy() {
    this.getButtons().forEach((button) => {
      button.removeEventListener('click', this.onPromoteButtonClick);
    });
  },
  methods: {
    onPromoteButtonClick(event) {
      const button = event.currentTarget;
      this.visible = true;
      this.milestoneTitle = button.dataset.milestoneTitle;
      this.url = button.dataset.url;
      this.groupName = button.dataset.groupName;
      this.currentButton = button;
    },
    getButtons() {
      return document.querySelectorAll('.js-promote-project-milestone-button');
    },
    onSubmit() {
      if (this.currentButton) {
        this.currentButton.setAttribute('disabled', '');
      }
      return axios
        .post(this.url, { params: { format: 'json' } })
        .then((response) => {
          this.visible = false;
          visitUrl(response.data.url);
        })
        .catch((error) => {
          this.visible = false;
          if (this.currentButton) {
            this.currentButton.removeAttribute('disabled');
          }
          createFlash(error);
        });
    },
    onClose() {
      this.visible = false;
    },
  },
  primaryAction: {
    text: s__('Milestones|Promote Milestone'),
    attributes: [{ variant: 'warning' }],
  },
  cancelAction: {
    text: s__('Cancel'),
    attributes: [],
  },
};
</script>
<template>
  <gl-modal
    :visible="visible"
    modal-id="promote-milestone-modal"
    :action-primary="$options.primaryAction"
    :action-cancel="$options.cancelAction"
    :title="title"
    @primary="onSubmit"
    @cancel="onClose"
    @close="onClose"
  >
    <p>{{ text }}</p>
    <p>{{ s__('Milestones|This action cannot be reversed.') }}</p>
  </gl-modal>
</template>
