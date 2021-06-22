import { GlLink } from '@gitlab/ui';
import { shallowMount } from '@vue/test-utils';
import Commit from 'ee/vulnerabilities/components/generic_report/types/commit.vue';

const TEST_DATA = {
  value: '24922148',
};

describe('ee/vulnerabilities/components/generic_report/types/commit.vue', () => {
  let wrapper;

  const createWrapper = ({ provide } = {}) => {
    return shallowMount(Commit, {
      propsData: TEST_DATA,
      provide: {
        projectFullPath: '',
        ...provide,
      },
    });
  };

  const findLink = () => wrapper.findComponent(GlLink);

  afterEach(() => {
    wrapper.destroy();
  });

  it.each(['/foo/bar', 'foo/bar'])(
    'given `projectFullPath` is "%s" it links to the absolute path of the commit',
    (projectFullPath) => {
      const absoluteCommitPath = `/foo/bar/-/commit/${TEST_DATA.value}`;

      wrapper = createWrapper({ provide: { projectFullPath } });

      expect(findLink().attributes('href')).toBe(absoluteCommitPath);
    },
  );

  it('shows the value as the link-text', () => {
    wrapper = createWrapper();

    expect(findLink().text()).toBe(TEST_DATA.value);
  });
});
