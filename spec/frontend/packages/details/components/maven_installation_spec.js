import { shallowMount, createLocalVue } from '@vue/test-utils';
import { nextTick } from 'vue';
import Vuex from 'vuex';
import { registryUrl as mavenPath } from 'jest/packages/details/mock_data';
import { mavenPackage as packageEntity } from 'jest/packages/mock_data';
import InstallationTitle from '~/packages/details/components/installation_title.vue';
import MavenInstallation from '~/packages/details/components/maven_installation.vue';
import { TrackingActions } from '~/packages/details/constants';
import CodeInstructions from '~/vue_shared/components/registry/code_instruction.vue';

const localVue = createLocalVue();
localVue.use(Vuex);

describe('MavenInstallation', () => {
  let wrapper;

  const xmlCodeBlock = 'foo/xml';
  const mavenCommandStr = 'foo/command';
  const mavenSetupXml = 'foo/setup';
  const gradleInstallCommandText = 'foo/gradle/install';
  const gradleAddSourceCommandText = 'foo/gradle/add/source';

  const store = new Vuex.Store({
    state: {
      packageEntity,
      mavenPath,
    },
    getters: {
      mavenInstallationXml: () => xmlCodeBlock,
      mavenInstallationCommand: () => mavenCommandStr,
      mavenSetupXml: () => mavenSetupXml,
      gradleInstalCommand: () => gradleInstallCommandText,
      gradleAddSourceCommand: () => gradleAddSourceCommandText,
    },
  });

  const findCodeInstructions = () => wrapper.findAll(CodeInstructions);
  const findInstallationTitle = () => wrapper.findComponent(InstallationTitle);

  function createComponent({ data = {} } = {}) {
    wrapper = shallowMount(MavenInstallation, {
      localVue,
      store,
      data() {
        return data;
      },
    });
  }

  afterEach(() => {
    wrapper.destroy();
  });

  describe('install command switch', () => {
    it('has the installation title component', () => {
      createComponent();

      expect(findInstallationTitle().exists()).toBe(true);
      expect(findInstallationTitle().props()).toMatchObject({
        storageKey: 'package_maven_installation_instructions',
        options: [
          { value: 'maven', label: 'Show Gradle commands' },
          { value: 'gradle', label: 'Show Maven commands' },
        ],
      });
    });

    it('on change event updates the instructions to show', async () => {
      createComponent();

      expect(findCodeInstructions().at(0).props('instruction')).toBe(xmlCodeBlock);
      findInstallationTitle().vm.$emit('change', 'gradle');

      await nextTick();

      expect(findCodeInstructions().at(0).props('instruction')).toBe(gradleInstallCommandText);
    });
  });

  describe('maven', () => {
    beforeEach(() => {
      createComponent();
    });

    it('renders all the messages', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    describe('installation commands', () => {
      it('renders the correct xml block', () => {
        expect(findCodeInstructions().at(0).props()).toMatchObject({
          instruction: xmlCodeBlock,
          multiline: true,
          trackingAction: TrackingActions.COPY_MAVEN_XML,
        });
      });

      it('renders the correct maven command', () => {
        expect(findCodeInstructions().at(1).props()).toMatchObject({
          instruction: mavenCommandStr,
          multiline: false,
          trackingAction: TrackingActions.COPY_MAVEN_COMMAND,
        });
      });
    });

    describe('setup commands', () => {
      it('renders the correct xml block', () => {
        expect(findCodeInstructions().at(2).props()).toMatchObject({
          instruction: mavenSetupXml,
          multiline: true,
          trackingAction: TrackingActions.COPY_MAVEN_SETUP,
        });
      });
    });
  });

  describe('gradle', () => {
    beforeEach(() => {
      createComponent({ data: { instructionType: 'gradle' } });
    });

    it('renders all the messages', () => {
      expect(wrapper.element).toMatchSnapshot();
    });

    describe('installation commands', () => {
      it('renders the gradle install command', () => {
        expect(findCodeInstructions().at(0).props()).toMatchObject({
          instruction: gradleInstallCommandText,
          multiline: false,
          trackingAction: TrackingActions.COPY_GRADLE_INSTALL_COMMAND,
        });
      });
    });

    describe('setup commands', () => {
      it('renders the correct gradle command', () => {
        expect(findCodeInstructions().at(1).props()).toMatchObject({
          instruction: gradleAddSourceCommandText,
          multiline: true,
          trackingAction: TrackingActions.COPY_GRADLE_ADD_TO_SOURCE_COMMAND,
        });
      });
    });
  });
});
