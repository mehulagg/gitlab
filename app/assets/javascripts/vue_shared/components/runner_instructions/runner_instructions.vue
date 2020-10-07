<script>
import {
  GlAlert,
  GlButton,
  GlModal,
  GlModalDirective,
  GlButtonGroup,
  GlDropdown,
  GlDropdownItem,
  GlIcon,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import getPlatformInstructions from './graphql/queries/get_platform_instructions.query.graphql';

export default {
  components: {
    GlAlert,
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
  inject: {
    instructionsPath: {
      default: '',
    },
  },
  apollo: {
    platforms: {
      query: getPlatformInstructions,
      update(data) {
        return data.platform;
      },
      error() {
        this.showAlert = true;
      },
    },
  },
  data() {
    return {
      showAlert: false,
      platforms: [],
      selectedPlatform: {},
      selectedArchitecture: {},
    };
  },
  computed: {
    closeButton() {
      return {
        text: __('Close'),
        attributes: [{ variant: 'default' }],
      };
    },
    isArchitectureSelected() {
      return this.selectedArchitecture !== '';
    },
    currentArchitectures() {
      return this.selectedPlatform.architectures;
    },
    installationInstructions() {
      return Object.keys(this.selectedArchitecture).length > 0
        ? this.selectedArchitecture.installationInstructions
        : '';
    },
    registerInstructions() {
      return Object.keys(this.selectedArchitecture).length > 0
        ? this.selectedArchitecture.registerInstructions
        : '';
    },
  },
  methods: {
    selectPlatform(name) {
      this.selectedPlatform = this.platforms.find(platform => platform.name === name);
    },
    selectArchitecture(name) {
      this.selectedArchitecture = this.currentArchitectures.find(
        architecture => architecture.name === name,
      );
    },
    toggleAlert(state) {
      this.showAlert = state;
    },
  },
  modalId: 'installation-instructions-modal',
  i18n: {
    installARunner: __('Install a Runner'),
    architecture: __('Architecture'),
    downloadInstallBinary: s__('Runners|Download and Install Binary'),
    downloadLatestBinary: s__('Runners|Download Latest Binary'),
    registerRunner: s__('Runners|Register Runner'),
    method: __('Method'),
    genericError: __('An error has occurred'),
    instructions: __('Show Runner installation instructions'),
  },
};
</script>
<template>
  <div>
    <gl-button v-gl-modal-directive="$options.modalId" data-testid="show-modal-button">
      {{ $options.i18n.instructions }}
    </gl-button>
    <gl-modal
      :modal-id="$options.modalId"
      :title="$options.i18n.installARunner"
      :action-secondary="closeButton"
    >
      <gl-alert v-if="showAlert" variant="danger" @dismiss="toggleAlert(false)">
        {{ $options.i18n.genericError }}
      </gl-alert>
      <h5>{{ __('Environment') }}</h5>
      <gl-button-group class="gl-mb-5">
        <gl-button
          v-for="platform in platforms"
          :key="platform.name"
          data-testid="platform-button"
          @click="selectPlatform(platform.name)"
        >
          {{ platform.humanReadableName }}
        </gl-button>
      </gl-button-group>
      <template>
        <h5>
          {{ $options.i18n.architecture }}
        </h5>
        <gl-dropdown class="gl-mb-5" :text="selectedArchitecture.name">
          <gl-dropdown-item
            v-for="architecture in currentArchitectures"
            :key="architecture.name"
            data-testid="architecture-dropdown-item"
            @click="selectArchitecture(architecture.name)"
          >
            {{ architecture.name }}
          </gl-dropdown-item>
        </gl-dropdown>
        <div class="gl-display-flex gl-align-items-center gl-mb-5">
          <h5>{{ $options.i18n.downloadInstallBinary }}</h5>
          <gl-button
            class="gl-ml-auto"
            :href="selectedArchitecture.downloadLocation"
            data-testid="binary-download-button"
          >
            {{ $options.i18n.downloadLatestBinary }}
          </gl-button>
        </div>
      </template>
      <template>
        <div class="gl-display-flex">
          <pre class="bg-light gl-flex-fill-1" data-testid="binary-instructions">
            {{ installationInstructions }}
          </pre>
          <gl-button
            class="gl-align-self-start gl-ml-2 gl-mt-2"
            category="tertiary"
            variant="link"
            :data-clipboard-text="installationInstructions"
          >
            <gl-icon name="copy-to-clipboard" />
          </gl-button>
        </div>

        <hr />
        <h5 class="gl-mb-5">{{ $options.i18n.registerRunner }}</h5>
        <h5 class="gl-mb-5">{{ $options.i18n.method }}</h5>
        <div class="gl-display-flex">
          <pre class="bg-light gl-flex-fill-1" data-testid="runner-instructions">
            {{ registerInstructions }}
          </pre>
          <gl-button
            class="gl-align-self-start gl-ml-2 gl-mt-2"
            category="tertiary"
            variant="link"
            :data-clipboard-text="registerInstructions"
          >
            <gl-icon name="copy-to-clipboard" />
          </gl-button>
        </div>
      </template>
    </gl-modal>
  </div>
</template>
