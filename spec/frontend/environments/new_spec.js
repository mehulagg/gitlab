import MockAdapter from 'axios-mock-adapter';
import { mountExtended } from 'helpers/vue_test_utils_helper';
import waitForPromises from 'helpers/wait_for_promises';
import NewEnvironment from '~/environments/components/new.vue';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { visitUrl } from '~/lib/utils/url_utility';

jest.mock('~/lib/utils/url_utility');
jest.mock('~/flash');

const DEFAULT_OPTS = {
  provide: { projectEnvironmentsPath: '/projects/environments' },
};

describe('~/environments/components/new.vue', () => {
  let wrapper;
  let mock;

  const createWrapper = (opts = {}) =>
    mountExtended(NewEnvironment, {
      ...DEFAULT_OPTS,
      ...opts,
    });

  beforeEach(() => {
    mock = new MockAdapter(axios);
    wrapper = createWrapper();
  });

  afterEach(() => {
    mock.restore();
    wrapper.destroy();
  });

  it('sets the title to New environment', () => {
    const header = wrapper.findByRole('heading', { name: 'New environment' });
    expect(header.exists()).toBe(true);
  });

  it('changes the environment name when inputted', async () => {
    const expected = 'test';
    const name = wrapper.findByLabelText('Name');

    await name.setValue(expected);

    expect(name.element.value).toBe(expected);
  });

  it('changes the environment url when inputted', async () => {
    const expected = 'https://example.com';
    const url = wrapper.findByLabelText('External URL');

    await url.setValue(expected);

    expect(url.element.value).toBe(expected);
  });

  it('submits the new environment on submit', async () => {
    const expected = { name: 'test', url: 'https://google.ca' };

    mock
      .onPost(DEFAULT_OPTS.provide.projectEnvironmentsPath, {
        name: expected.name,
        external_url: expected.url,
      })
      .reply(200, { path: '/test' });

    const name = wrapper.findByLabelText('Name');
    const url = wrapper.findByLabelText('External URL');
    const form = wrapper.findByRole('form', { name: 'New environment' });

    await name.setValue(expected.name);
    await url.setValue(expected.url);

    await form.trigger('submit');
    await waitForPromises();

    expect(visitUrl).toHaveBeenCalledWith('/test');
  });

  it('shows errrors on error', async () => {
    const expected = { name: 'test', url: 'https://google.ca' };

    mock
      .onPost(DEFAULT_OPTS.provide.projectEnvironmentsPath, {
        name: expected.name,
        external_url: expected.url,
      })
      .reply(400, { message: ['name taken'] });

    const name = wrapper.findByLabelText('Name');
    const url = wrapper.findByLabelText('External URL');
    const form = wrapper.findByRole('form', { name: 'New environment' });

    await name.setValue(expected.name);
    await url.setValue(expected.url);

    await form.trigger('submit');
    await waitForPromises();

    expect(createFlash).toHaveBeenCalledWith({ message: 'name taken' });
  });
});
