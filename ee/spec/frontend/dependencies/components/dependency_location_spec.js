import { GlLink, GlIntersperse, GlPopover } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import DependencyLocation from 'ee/dependencies/components/dependency_location.vue';
import DependencyPathViewer from 'ee/dependencies/components/dependency_path_viewer.vue';
import { trimText } from 'helpers/text_helper';
import * as Paths from './mock_data';

describe('Dependency Location component', () => {
  let wrapper;

  const createComponent = ({ propsData, ...options } = {}) => {
    wrapper = shallowMount(DependencyLocation, {
      propsData: { ...propsData },
      stubs: { GlLink, DependencyPathViewer, GlIntersperse },
      provide: {
        glFeatures: {
          pathToVulnerableDependency: true,
        },
      },
      ...options,
    });
  };

  const findPopover = () => wrapper.find(GlPopover);

  afterEach(() => {
    wrapper.destroy();
  });

  it.each`
    name                | location              | path
    ${'no path'}        | ${Paths.noPath}       | ${'package.json'}
    ${'top level path'} | ${Paths.topLevelPath} | ${'package.json (top level)'}
    ${'short path'}     | ${Paths.shortPath}    | ${'package.json / swell 1.2 / emmajsq 10.11'}
    ${'long path'}      | ${Paths.longPath}     | ${'package.json / swell 1.2 / emmajsq 10.11 / 3 more'}
  `('shows dependency path for $name', ({ location, path }) => {
    createComponent({
      propsData: {
        location,
      },
    });

    expect(trimText(wrapper.text())).toContain(path);
  });

  describe('popover', () => {
    beforeEach(() => {
      createComponent({
        propsData: {
          location: Paths.longPath,
        },
      });
    });

    it('should render the popover', () => {
      expect(findPopover().exists()).toBe(true);
    });

    it('should have the complete path', () => {
      expect(trimText(findPopover().text())).toBe(
        'swell 1.2 / emmajsq 10.11 / zeb 12.1 / post 2.5 / core 1.0 There may be multiple paths',
      );
    });
  });

  describe('dependency with no dependency path', () => {
    beforeEach(() => {
      createComponent({
        propsData: {
          location: Paths.noPath,
        },
      });
    });

    it('should show the depedency name and link', () => {
      const locationLink = wrapper.find(GlLink);
      expect(locationLink.attributes().href).toBe('test.link');
      expect(locationLink.text()).toBe('package.json');
    });

    it('should not render dependency path', () => {
      const pathViewer = wrapper.find(DependencyPathViewer);
      expect(pathViewer.exists()).toBe(false);
    });

    it('should not render the popover', () => {
      expect(findPopover().exists()).toBe(false);
    });
  });

  describe('with feature flag off', () => {
    it.each`
      name                | location              | path
      ${'no path'}        | ${Paths.noPath}       | ${'package.json'}
      ${'top level path'} | ${Paths.topLevelPath} | ${'package.json'}
      ${'short path'}     | ${Paths.shortPath}    | ${'package.json'}
      ${'long path'}      | ${Paths.longPath}     | ${'package.json'}
    `('do not show dependency path for $name', ({ location, path }) => {
      createComponent({
        propsData: {
          location,
        },
        provide: { glFeatures: { pathToVulnerableDependency: false } },
      });

      expect(wrapper.text()).toBe(path);
    });
  });
});
