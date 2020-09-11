<script>
import {
  GlModal,
  GlDropdown,
  GlDropdownItem,
  GlDatepicker,
  GlLink,
  GlSprintf,
  GlSearchBoxByType,
} from '@gitlab/ui';
import eventHub from '../event_hub';
import { s__ } from '~/locale';
import Api from '~/api';

export default {
  name: 'InviteMembersModal',
  components: {
    GlDatepicker,
    GlLink,
    GlModal,
    GlDropdown,
    GlDropdownItem,
    GlSprintf,
    GlSearchBoxByType,
  },
  props: {
    groupId: {
      type: String,
      required: true,
    },
    groupName: {
      type: String,
      required: true,
    },
    accessLevels: {
      type: Object,
      required: true,
    },
    defaultAccessLevel: {
      type: String,
      required: true,
    },
    helpLink: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      visible: true,
      modalId: 'invite-members-modal',
      selectedAccessLevel: this.defaultAccessLevel,
      newUsersToInvite: '',
      selectedDate: undefined,
    };
  },
  computed: {
    introText() {
      return s__(`InviteMembersModal|You're inviting members to the ${this.groupName} group`);
    },
    toastOptions() {
      return {
        onComplete: () => {
          this.selectedAccessLevel = this.defaultAccessLevel;
          this.newUsersToInvite = '';
        },
      };
    },
    postData() {
      return {
        user_id: this.newUsersToInvite,
        access_level: this.selectedAccessLevel,
        expires_at: this.selectedDate,
        format: 'json',
      };
    },
    selectedRoleName() {
      return Object.keys(this.accessLevels).find(
        key => this.accessLevels[key] === Number(this.selectedAccessLevel),
      );
    },
  },
  mounted() {
    eventHub.$on('openModal', this.openModal);
  },
  methods: {
    openModal() {
      this.$root.$emit('bv::show::modal', this.modalId);
    },
    closeModal() {
      this.$root.$emit('bv::hide::modal', this.modalId);
    },
    sendInvite() {
      this.submitForm(this.postData);
    },
    cancelInvite() {
      this.selectedAccessLevel = this.defaultAccessLevel;
      this.selectedDate = undefined;
      this.newUsersToInvite = '';
    },
    changeSelectedItem(item) {
      this.selectedAccessLevel = item;
    },
    submitForm(formData) {
      return Api.inviteGroupMember(this.groupId, formData)
        .then(() => {
          this.showToastMessageSuccess();
        })
        .catch(error => {
          this.showToastMessageError(error);
        });
    },
    showToastMessageSuccess() {
      this.$toast.show(this.$options.labels.toastMessageSuccessful, this.toastOptions);
    },
    showToastMessageError(error) {
      const message = error.response.data.message || this.$options.labels.toastMessageUnsuccessful;

      this.$toast.show(message, this.toastOptions);
    },
  },
  labels: {
    modalTitle: s__('InviteMembersModal|Invite team members'),
    userToInvite: s__('InviteMembersModal|GitLab member or Email address'),
    userPlaceholder: s__('InviteMembersModal|Search for members to invite'),
    accessLevel: s__('InviteMembersModal|Choose a role permission'),
    accessExpireDate: s__('InviteMembersModal|Access expiration date (optional)'),
    toastMessageSuccessful: s__('InviteMembersModal|Users were succesfully added'),
    toastMessageUnsuccessful: s__('InviteMembersModal|User not invited. Feature coming soon!'),
    readMoreText: s__(`InviteMembersModal|%{linkStart}Read more%{linkEnd} about role permissions`),
    inviteButtonText: s__('InviteMembersModal|Invite'),
    cancelButtonText: s__('InviteMembersModal|Cancel'),
  },
};
</script>
<template>
  <gl-modal
    :modal-id="modalId"
    size="sm"
    :title="$options.labels.modalTitle"
    modal-class="set-user-status-modal"
    :ok-title="$options.labels.inviteButtonText"
    :cancel-title="$options.labels.cancelButtonText"
    ok-variant="success"
    @ok="sendInvite"
    @cancel="cancelInvite"
  >
    <div class="gl-ml-5 gl-mr-5">
      <div>{{ introText }}</div>

      <label class="gl-font-weight-bold gl-mt-5">{{ $options.labels.userToInvite }}</label>
      <div class="gl-mt-2">
        <gl-search-box-by-type
          v-model="newUsersToInvite"
          :placeholder="$options.labels.userPlaceholder"
          type="text"
          autocomplete="off"
          autocorrect="off"
          autocapitalize="off"
          spellcheck="false"
        />
      </div>

      <label class="gl-font-weight-bold gl-mt-5">{{ $options.labels.accessLevel }}</label>
      <div class="gl-mt-2 gl-w-half">
        <gl-dropdown
          menu-class="dropdown-menu-selectable"
          class="gl-shadow-none gl-w-full"
          v-bind="$attrs"
          :text="selectedRoleName"
        >
          <template v-for="(key, item) in accessLevels">
            <gl-dropdown-item
              :key="key"
              active-class="is-active"
              :is-checked="key === selectedAccessLevel"
              @click="changeSelectedItem(key)"
            >
              <div>{{ item }}</div>
            </gl-dropdown-item>
          </template>
        </gl-dropdown>
      </div>

      <div class="gl-mt-2">
        <gl-sprintf :message="$options.labels.readMoreText">
          <template #link="{content}">
            <gl-link :href="helpLink" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </div>

      <label class="gl-font-weight-bold gl-mt-5" for="expires_at">{{
        $options.labels.accessExpireDate
      }}</label>
      <div class="gl-mt-2">
        <gl-datepicker v-model="selectedDate" :min-date="new Date()" :target="null" />
      </div>
    </div>
  </gl-modal>
</template>
