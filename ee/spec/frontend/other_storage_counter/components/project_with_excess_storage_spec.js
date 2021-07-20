import { GlIcon, GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import ProjectWithExcessStorage from 'ee/other_storage_counter/components/project_with_excess_storage.vue';
import { formatUsageSize } from 'ee/other_storage_counter/utils';
import { createMockDirective, getBinding } from 'helpers/vue_mock_directive';
import ProjectAvatar from '~/vue_shared/components/deprecated_project_avatar/default.vue';
import { projects } from '../mock_data';

let wrapper;

const createComponent = (propsData = {}) => {
  wrapper = shallowMount(ProjectWithExcessStorage, {
    propsData: {
      project: projects[0],
      additionalPurchasedStorageSize: 0,
      ...propsData,
    },
    directives: {
      GlTooltip: createMockDirective(),
    },
  });
};

const findTableRow = () => wrapper.find('[data-testid="projectTableRow"]');
const findWarningIcon = () =>
  wrapper.findAll(GlIcon).wrappers.find((w) => w.props('name') === 'status_warning');
const findProjectLink = () => wrapper.find(GlLink);
const getWarningIconTooltipText = () => getBinding(findWarningIcon().element, 'gl-tooltip').value;

describe('Storage Counter project component', () => {
  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  describe('without extra storage purchased', () => {
    it('renders project avatar', () => {
      expect(wrapper.find(ProjectAvatar).exists()).toBe(true);
    });

    it('renders project name', () => {
      expect(wrapper.text()).toContain(projects[0].nameWithNamespace);
    });

    it('renders formatted storage size', () => {
      expect(wrapper.text()).toContain(formatUsageSize(projects[0].statistics.storageSize));
    });

    it('does not render the warning icon if project is not in error state', () => {
      expect(findWarningIcon()).toBe(undefined);
    });

    it('render row without error state background', () => {
      expect(findTableRow().classes('gl-bg-red-50')).toBe(false);
    });

    describe('renders the row in error state', () => {
      beforeEach(() => {
        createComponent({ project: projects[2] });
      });

      it('with error state background', () => {
        expect(findTableRow().classes('gl-bg-red-50')).toBe(true);
      });

      it('with project link in error state', () => {
        expect(findProjectLink().classes('gl-text-red-500!')).toBe(true);
      });

      it('with error icon', () => {
        expect(findWarningIcon().exists()).toBe(true);
      });

      it('with tooltip', () => {
        expect(getWarningIconTooltipText().title).toBe(
          'This project is locked because it is using 97.7KiB of free storage and there is no purchased storage available.',
        );
      });
    });

    describe('renders the row in warning state', () => {
      beforeEach(() => {
        createComponent({ project: projects[1] });
      });

      it('with warning state background', () => {
        expect(findTableRow().classes('gl-bg-orange-50')).toBe(true);
      });

      it('with project link in default gray state', () => {
        expect(findProjectLink().classes('gl-text-gray-900!')).toBe(true);
      });

      it('with warning icon', () => {
        expect(findWarningIcon().exists()).toBe(true);
      });

      it('with tooltip', () => {
        expect(getWarningIconTooltipText().title).toBe(
          'This project is near the free 97.7KiB limit and at risk of being locked.',
        );
      });
    });
  });

  describe('with extra storage purchased', () => {
    describe('if projects is in error state', () => {
      beforeEach(() => {
        createComponent({
          project: projects[2],
          additionalPurchasedStorageSize: 100000,
        });
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('renders purchased storage specific error tooltip ', () => {
        expect(getWarningIconTooltipText().title).toBe(
          'This project is locked because it used 97.7KiB of free storage and all the purchased storage.',
        );
      });
    });

    describe('if projects is in warning state', () => {
      beforeEach(() => {
        createComponent({
          project: projects[1],
          additionalPurchasedStorageSize: 100000,
        });
      });

      afterEach(() => {
        wrapper.destroy();
      });

      it('renders purchased storage specific warning tooltip ', () => {
        expect(getWarningIconTooltipText().title).toBe(
          'This project is at risk of being locked because purchased storage is running low.',
        );
      });
    });
  });
});
