import { mount } from '@vue/test-utils';
import MavenInstallation from 'ee/packages/details/components/maven_installation.vue';
import { TrackingActions, TrackingLabels } from 'ee/packages/details/constants';
import {
  generateMavenCommand,
  generateXmlCodeBlock,
  generateMavenSetupXml,
  mavenMetadata,
  registryUrl,
} from '../mock_data';
import Tracking from '~/tracking';

describe('MavenInstallation', () => {
  let wrapper;

  const defaultProps = {
    mavenMetadata,
    registryUrl,
    helpUrl: 'foo',
  };

  const mavenCommandStr = generateMavenCommand(mavenMetadata);
  const xmlCodeBlock = generateXmlCodeBlock(mavenMetadata);
  const mavenSetupXml = generateMavenSetupXml();

  const installationTab = () => wrapper.find('.js-installation-tab > a');
  const setupTab = () => wrapper.find('.js-setup-tab > a');
  const xmlCode = () => wrapper.find('.js-maven-xml > pre');
  const mavenCommand = () => wrapper.find('.js-maven-command > input');
  const xmlSetup = () => wrapper.find('.js-maven-setup-xml > pre');

  function createComponent(props = {}) {
    const propsData = {
      ...defaultProps,
      ...props,
    };

    wrapper = mount(MavenInstallation, {
      propsData,
    });
  }

  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  describe('with empty maven metadata', () => {
    beforeEach(() => {
      createComponent({
        mavenMetadata: {},
      });
    });

    it('renders empty strings in the xml block', () => {
      const emptyXmlBlock = generateXmlCodeBlock({});

      expect(xmlCode().text()).toBe(emptyXmlBlock);
    });

    it('renders empty strings in the command block', () => {
      const emptyMavenCommand = generateMavenCommand({});

      expect(mavenCommand().element.value).toBe(emptyMavenCommand);
    });
  });

  describe('installation commands', () => {
    it('renders the correct xml block', () => {
      expect(xmlCode().text()).toBe(xmlCodeBlock);
    });

    it('renders the correct maven command', () => {
      expect(mavenCommand().element.value).toBe(mavenCommandStr);
    });
  });

  describe('setup commands', () => {
    it('renders the correct xml block', () => {
      expect(xmlSetup().text()).toBe(mavenSetupXml);
    });
  });

  describe('tab change tracking', () => {
    let eventSpy;
    const label = TrackingLabels.MAVEN_INSTALLATION;

    beforeEach(() => {
      eventSpy = jest.spyOn(Tracking, 'event');
    });

    it('should track when the setup tab is clicked', () => {
      setupTab().trigger('click');

      expect(eventSpy).toHaveBeenCalledWith(undefined, TrackingActions.REGISTRY_SETUP, {
        label,
      });
    });

    it('should track when the installation tab is clicked', () => {
      setupTab().trigger('click');
      return wrapper.vm
        .$nextTick()
        .then(() => {
          installationTab().trigger('click');
        })
        .then(() => {
          expect(eventSpy).toHaveBeenCalledWith(undefined, TrackingActions.INSTALLATION, {
            label,
          });
        });
    });
  });
});
