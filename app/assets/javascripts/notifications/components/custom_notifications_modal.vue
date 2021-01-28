<script>
import { GlModal, GlSprintf, GlLink, GlLoadingIcon, GlFormGroup, GlFormCheckbox } from '@gitlab/ui';
import { i18n } from '../constants';
import Api from '~/api';

export default {
  name: 'CustomNotificationsModal',
  components: {
    GlModal,
    GlSprintf,
    GlLink,
    GlLoadingIcon,
    GlFormGroup,
    GlFormCheckbox,
  },
  inject: {
    projectId: {
      default: null,
    },
    groupId: {
      default: null,
    },
    helpPagePath: {
      default: '',
    },
  },
  props: {
    modalId: {
      type: String,
      required: false,
      default: 'custom-notifications-modal',
    },
  },
  data() {
    return {
      isLoading: false,
      events: [],
    };
  },
  /*
  async mounted() {
    await this.loadNotificationSettings();
  },
  */
  methods: {
    open() {
      this.$refs.modal.show();
    },
    buildEvents(events) {
      return Object.keys(events).map((key) => ({
        id: key,
        enabled: Boolean(events[key]),
        name: this.$options.i18n.eventNames[key] || '',
        loading: false,
      }));
    },
    async onOpen() {
      if (!this.events.length) {
        await this.loadNotificationSettings();
      }
    },
    async loadNotificationSettings() {
      console.log('CustomNotificationsModal :: loadNotificationSettings ');
      this.isLoading = true;

      try {
        const {
          data: { events },
        } = await Api.getNotificationSettings(this.projectId, this.groupId);

        console.log('CustomNotificationsModal :: loadNotificationSettings : ', events);

        this.events = this.buildEvents(events);
      } finally {
        this.isLoading = false;
      }
    },
    async updateEvent(isEnabled, event) {
      console.log('CustomNotificationsModal :: updateEvent : ', isEnabled, event);

      const index = this.events.findIndex((e) => e.id === event.id);

      // update loading state for the given event
      this.$set(this.events, index, { ...this.events[index], loading: true });

      try {
        const {
          data: { events },
        } = await Api.updateNotificationSettings(this.projectId, this.groupId, {
          [event.id]: isEnabled,
        });

        this.events = this.buildEvents(events);
      } catch (error) {
        throw error;
      }
    },
  },
  i18n,
};
</script>

<template>
  <gl-modal ref="modal" :modal-id="modalId" @show="onOpen">
    <template #modal-title>{{ $options.i18n.customNotificationsModal.title }}</template>
    <div class="container-fluid">
      <div class="row">
        <div class="col-lg-4">
          <h4 class="gl-mt-0">{{ $options.i18n.customNotificationsModal.bodyTitle }}</h4>
          <gl-sprintf :message="$options.i18n.customNotificationsModal.bodyMessage">
            <template #notificationLink="{ content }">
              <gl-link :href="helpPagePath" target="_blank">{{ content }}</gl-link>
            </template>
          </gl-sprintf>
        </div>
        <div class="col-lg-8">
          <gl-loading-icon v-if="isLoading" size="lg" class="gl-mt-3" />
          <template v-else>
            <gl-form-group v-for="event in events" :key="event.id">
              <gl-form-checkbox v-model="event.enabled" @change="updateEvent($event, event)">
                <strong>{{ event.name }}</strong
                ><gl-loading-icon v-if="event.loading" :inline="true" class="gl-ml-2" />
              </gl-form-checkbox>
            </gl-form-group>
          </template>
        </div>
      </div>
    </div>
    <template #modal-footer></template>
  </gl-modal>
</template>
