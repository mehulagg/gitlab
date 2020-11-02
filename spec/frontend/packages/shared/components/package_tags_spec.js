import { mount } from '@vue/test-utils';
import { GlBreakpointInstance } from '@gitlab/ui/dist/utils';
import PackageTags from '~/packages/shared/components/package_tags.vue';
import { mockTags } from '../../mock_data';

describe('PackageTags', () => {
  let wrapper;

  function createComponent(tags = [], props = {}) {
    const propsData = {
      tags,
      ...props,
    };

    wrapper = mount(PackageTags, {
      propsData,
    });
  }

  const tagLabel = () => wrapper.find('[data-testid="tagLabel"]');
  const tagBadges = () => wrapper.findAll('[data-testid="tagBadge"]');
  const moreBadge = () => wrapper.find('[data-testid="moreBadge"]');

  afterEach(() => {
    if (wrapper) wrapper.destroy();
  });

  describe('tag label', () => {
    it('shows the tag label by default', () => {
      createComponent();

      expect(tagLabel().exists()).toBe(true);
    });

    it('hides when hideLabel prop is set to true', () => {
      createComponent(mockTags, { hideLabel: true });

      expect(tagLabel().exists()).toBe(false);
    });
  });

  it('renders the correct number of tags', () => {
    createComponent(mockTags.slice(0, 2));

    expect(tagBadges()).toHaveLength(2);
    expect(moreBadge().exists()).toBe(false);
  });

  it('does not render more than the configured tagDisplayLimit', () => {
    createComponent(mockTags);

    expect(tagBadges()).toHaveLength(2);
  });

  it('renders the more tags badge if there are more than the configured limit', () => {
    createComponent(mockTags);

    expect(tagBadges()).toHaveLength(2);
    expect(moreBadge().exists()).toBe(true);
    expect(moreBadge().text()).toContain('2');
  });

  it('renders the configured tagDisplayLimit when set in props', () => {
    createComponent(mockTags, { tagDisplayLimit: 1 });

    expect(tagBadges()).toHaveLength(1);
    expect(moreBadge().exists()).toBe(true);
    expect(moreBadge().text()).toContain('3');
  });

  describe('tagBadgeStyle', () => {
    const defaultStyle = ['badge', 'badge-info', 'gl-display-flex'];

    it('shows tag badge when there is only one', () => {
      createComponent([mockTags[0]]);

      const expectedStyle = [...defaultStyle, 'gl-ml-3'];

      expect(
        tagBadges()
          .at(0)
          .classes(),
      ).toEqual(expect.arrayContaining(expectedStyle));
    });

    it('shows default style for medium or higher resolutions', () => {
      createComponent(mockTags);

      expect(
        tagBadges()
          .at(1)
          .classes(),
      ).toEqual(expect.arrayContaining(defaultStyle));
    });

    it('shows all the tags for mobile resolution', async () => {
      jest.spyOn(GlBreakpointInstance, 'isDesktop').mockReturnValue(false);

      createComponent(mockTags, {
        tagDisplayLimit: 1,
      });

      const mobileStyle = [...defaultStyle, 'gl-mt-2'];

      await wrapper.vm.$nextTick();

      expect(
        tagBadges()
          .at(0)
          .classes(),
      ).toEqual(expect.arrayContaining(mobileStyle));

      expect(tagBadges()).toHaveLength(mockTags.length);
    });

    it('correctly prepends left and appends right when there is more than one tag', () => {
      createComponent(mockTags, {
        tagDisplayLimit: 4,
      });

      const expectedStyleWithAppend = [...defaultStyle, 'gl-mr-2'];

      const allBadges = tagBadges();

      expect(allBadges.at(0).classes()).toEqual(
        expect.arrayContaining([...expectedStyleWithAppend, 'gl-ml-3']),
      );
      expect(allBadges.at(1).classes()).toEqual(expect.arrayContaining(expectedStyleWithAppend));
      expect(allBadges.at(2).classes()).toEqual(expect.arrayContaining(expectedStyleWithAppend));
      expect(allBadges.at(3).classes()).toEqual(expect.arrayContaining(defaultStyle));
    });
  });
});
