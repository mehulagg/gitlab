<script>
import { GlFormCheckbox, GlModal, GlSprintf, GlLink } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import csrf from '~/lib/utils/csrf';
import { __ } from '~/locale';

const schedules = [
  {
    id: 1,
    name: __('Schedule 1'),
    link: 'gitlab.com',
    projectName: __('Some of the projects'),
    projectPath: '#',
  },
  {
    id: 2,
    name: __('Schedule 2'),
    link: 'gitlab.com',
    projectName: __('Some of the projects'),
    projectPath: '#',
  },
  {
    id: 3,
    name: __('Schedule 3'),
    link: 'gitlab.com',
    projectName: __('Some of thep rojects'),
    projectPath: '#',
  },
];

export default {
  actionCancel: {
    text: __('Cancel'),
  },
  csrf,
  components: {
    GlFormCheckbox,
    GlModal,
    GlSprintf,
    GlLink,
  },
  data() {
    return {
      schedules,
      modalData: {},
    };
  },
  computed: {
    isAccessRequest() {
      return parseBoolean(this.modalData.isAccessRequest);
    },
    isGroupMember() {
      return this.modalData.memberType === 'GroupMember';
    },
    actionText() {
      return this.isAccessRequest ? __('Deny access request') : __('Remove member');
    },
    actionPrimary() {
      return {
        text: this.actionText,
        attributes: {
          variant: 'danger',
        },
      };
    },
    isPartOfOncallSchedules() {
      return !this.isAccessRequest && this.modalData.schedules;
    },
  },
  mounted() {
    document.addEventListener('click', this.handleClick);
  },
  beforeDestroy() {
    document.removeEventListener('click', this.handleClick);
  },
  methods: {
    handleClick(event) {
      const removeButton = event.target.closest('.js-remove-member-button');
      if (removeButton) {
        this.modalData = removeButton.dataset;
        this.modalData.schedules = schedules;
        this.modalData.userName = __('Lena');
        this.$refs.modal.show();
      }
    },
    submitForm() {
      this.$refs.form.submit();
    },
  },
};
</script>

<template>
  <gl-modal
    ref="modal"
    modal-id="remove-member-modal"
    :action-cancel="$options.actionCancel"
    :action-primary="actionPrimary"
    :title="actionText"
    data-qa-selector="remove_member_modal_content"
    @primary="submitForm"
  >
    <form ref="form" :action="modalData.memberPath" method="post">
      <p data-testid="modal-message">{{ modalData.message }}</p>

      <div v-if="isPartOfOncallSchedules" data-testid="modal-schedules">
        <p>
          <gl-sprintf :message="__('User %{user} is currently part of:')">
            <template #user>
              {{ modalData.userName }}
            </template>
          </gl-sprintf>
        </p>

        <ul>
          <li v-for="schedule in schedules" :key="schedule.id">
            <gl-sprintf :message="__('On-call schedule %{schedule} in Project %{project}')">
              <template #schedule>
                <gl-link :href="schedule.link">{{ schedule.name }}</gl-link>
              </template>
              <template #project>
                <gl-link :href="schedule.projectPath">>{{ schedule.projectName }}</gl-link>
              </template>
            </gl-sprintf>
          </li>
        </ul>
      </div>

      <input ref="method" type="hidden" name="_method" value="delete" />
      <input :value="$options.csrf.token" type="hidden" name="authenticity_token" />
      <gl-form-checkbox v-if="isGroupMember" name="remove_sub_memberships">
        {{ __('Also remove direct user membership from subgroups and projects') }}
      </gl-form-checkbox>
      <gl-form-checkbox v-if="!isAccessRequest" name="unassign_issuables">
        {{ __('Also unassign this user from related issues and merge requests') }}
      </gl-form-checkbox>
    </form>
  </gl-modal>
</template>
