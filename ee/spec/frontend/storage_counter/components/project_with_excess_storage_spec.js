import { shallowMount } from '@vue/test-utils';
import { GlLink } from '@gitlab/ui';
import ProjectWithExcessStorage from 'ee/storage_counter/components/project_with_excess_storage.vue';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { projects } from '../mock_data';

let wrapper;

const createComponent = (propsData = {}) => {
  wrapper = shallowMount(ProjectWithExcessStorage, {
    propsData: {
      project: projects[1],
      ...propsData,
    },
  });
};

const findTableRow = () => wrapper.find('[data-testid="projectTableRow"]');
const findWarningIcon = () => wrapper.find({ name: 'status_warning' });
const findProjectLink = () => wrapper.find(GlLink);

describe('Storage Counter project component', () => {
  beforeEach(() => {
    createComponent();
  });

  afterEach(() => {
    wrapper.destroy();
  });

  it('renders project avatar', () => {
    expect(wrapper.find(ProjectAvatar).exists()).toBe(true);
  });

  it('renders project name', () => {
    expect(wrapper.text()).toContain(projects[1].nameWithNamespace);
  });

  it('renders formatted storage size', () => {
    expect(wrapper.text()).toContain(numberToHumanSize(projects[1].statistics.storageSize));
  });

  it('does not render the warning icon if project is not in error state', () => {
    expect(findWarningIcon().exists()).toBe(false);
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
  });
});
