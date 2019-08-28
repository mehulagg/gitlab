import { shallowMount } from '@vue/test-utils';
import ReleaseBlock from '~/releases/components/release_block.vue';
import { release } from '../mock_data';

describe('Release block', () => {
  let wrapper;

  const factory = releaseProp => {
    wrapper = shallowMount(ReleaseBlock, {
      propsData: {
        release: releaseProp,
      },
      sync: false,
    });
  };

  const milestoneListExists = () => wrapper.find('.js-milestone-list').exists();
  const footerExists = () => wrapper.find('.card-footer').exists();

  afterEach(() => {
    wrapper.destroy();
  });

  it('does not render the milestone list if no milestones are associated to the release', () => {
    const releaseClone = JSON.parse(JSON.stringify(release));
    delete releaseClone.milestone;

    factory(releaseClone);

    expect(milestoneListExists()).toBe(false);
  });

  it('does not render the release block footer if no milestones are associated to the release', () => {
    const releaseClone = JSON.parse(JSON.stringify(release));
    delete releaseClone.milestone;

    factory(releaseClone);

    expect(footerExists()).toBe(false);
  });

  it('renders the milestone list if at least one milestone is associated to the release', () => {
    factory(release);

    expect(milestoneListExists()).toBe(true);
  });

  it('renders the release block footer if at least one milestone is associated to the release', () => {
    factory(release);

    expect(footerExists()).toBe(true);
  });
});
