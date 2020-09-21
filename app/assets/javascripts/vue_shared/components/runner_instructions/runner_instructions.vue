<script>
import {
  GlButton,
  GlModal,
  GlModalDirective,
  GlButtonGroup,
  GlDropdown,
  GlDropdownItem,
  GlIcon,
} from '@gitlab/ui';
import { mapActions, mapState, mapGetters } from 'vuex';
import { __, s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlButtonGroup,
    GlDropdown,
    GlDropdownItem,
    GlModal,
    GlIcon,
  },
  directives: {
    GlModalDirective,
  },
  computed: {
    ...mapState('installRunnerPopup', [
      'availablePlatforms',
      'instructions',
      'selectedArchitecture',
    ]),
    ...mapGetters('installRunnerPopup', [
      'getSupportedArchitectures',
      'instructionsEmpty',
      'hasDownloadLocationsAvailable',
      'getDownloadLocation',
    ]),
    closeButton() {
      return {
        text: __('Close'),
        attributes: [{ variant: 'default' }],
      };
    },
    isArchitectureSelected() {
      return this.selectedArchitecture !== '';
    },
  },
  mounted() {
    this.requestPlatforms();
  },
  methods: {
    ...mapActions('installRunnerPopup', [
      'requestPlatforms',
      'selectPlatform',
      'startInstructionsRequest',
    ]),
  },
  modalId: 'installation-instructions-modal',
  i18n: {
    installARunner: __('Install a Runner'),
    architecture: __('Architecture'),
    downloadInstallBinary: s__('Runners|Download and Install Binary'),
    downloadLatestBinary: s__('Runners|Download Latest Binary'),
    registerRunner: s__('Runners|Register Runner'),
    method: __('Method'),
  },
};
</script>
<template>
  <div>
    <gl-button v-gl-modal-directive="$options.modalId" data-testid="show-modal-button">
      {{ __('Show Runner installation instructions') }}
    </gl-button>
    <gl-modal
      :modal-id="$options.modalId"
      :title="$options.i18n.installARunner"
      :action-secondary="closeButton"
    >
      <h5>{{ __('Environment') }}</h5>
      <gl-button-group class="gl-mb-5">
        <gl-button
          v-for="(platform, key) in availablePlatforms"
          :key="key"
          data-testid="platform-button"
          @click="selectPlatform(key)"
        >
          {{ platform.human_readable_name }}
        </gl-button>
      </gl-button-group>
      <template v-if="hasDownloadLocationsAvailable">
        <h5>
          {{ $options.i18n.architecture }}
        </h5>
        <gl-dropdown class="gl-mb-5" :text="selectedArchitecture">
          <gl-dropdown-item
            v-for="(architecture, index) in getSupportedArchitectures"
            :key="index"
            data-testid="architecture-dropdown-item"
            @click="startInstructionsRequest(architecture)"
          >
            {{ architecture }}
          </gl-dropdown-item>
        </gl-dropdown>
        <div v-if="isArchitectureSelected" class="gl-display-flex gl-align-items-center gl-mb-5">
          <h5>{{ $options.i18n.downloadInstallBinary }}</h5>
          <gl-button
            class="gl-ml-auto"
            :href="getDownloadLocation"
            data-testid="binary-download-button"
          >
            {{ $options.i18n.downloadLatestBinary }}
          </gl-button>
        </div>
      </template>
      <template v-if="!instructionsEmpty">
        <div v-if="!instructionsEmpty" class="gl-display-flex">
          <pre class="bg-light gl-flex-fill-1" data-testid="binary-instructions">
            {{ instructions.install.trimStart() }}
          </pre>
          <gl-button
            class="gl-align-self-start gl-ml-2 gl-mt-2"
            category="tertiary"
            variant="link"
            :data-clipboard-text="instructions.install"
          >
            <gl-icon name="copy-to-clipboard" />
          </gl-button>
        </div>

        <hr />
        <h5 class="gl-mb-5">{{ $options.i18n.registerRunner }}</h5>
        <h5 class="gl-mb-5">{{ $options.i18n.method }}</h5>
        <div class="gl-display-flex">
          <pre class="bg-light gl-flex-fill-1" data-testid="runner-instructions">
            {{ instructions.register.trim() }}
          </pre>
          <gl-button
            class="gl-align-self-start gl-ml-2 gl-mt-2"
            category="tertiary"
            variant="link"
            :data-clipboard-text="instructions.register"
          >
            <gl-icon name="copy-to-clipboard" />
          </gl-button>
        </div>
      </template>
    </gl-modal>
  </div>
</template>
