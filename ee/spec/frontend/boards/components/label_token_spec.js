import { GlFilteredSearchToken, GlFilteredSearchSuggestion, GlFilteredSearchTokenSegment } from '@gitlab/ui';
import { mount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import LabelToken from 'ee/boards/components/label_token.vue';
import GroupLabelsQuery from 'ee/boards/graphql/group_labels.query.graphql';
import createMockApollo from 'helpers/mock_apollo_helper';
import waitForPromises from 'helpers/wait_for_promises';

const localVue = createLocalVue();

localVue.use(VueApollo);

const labels = [{ node: { id: 'first label', title: 'first label', color: 'red', textColor: 'white' }}, { node: { id: 'second label', title: 'second label', color: 'green', textColor: 'white' }}];

describe('LabelToken', () => {
  let mockApollo;
  let wrapper;
  let querySpy;

  const createComponentWithApollo = async (active = false) => {
    querySpy = jest.fn().mockResolvedValue({ data: { group: { labels: { edges: labels} }} })
    mockApollo = createMockApollo([
      [GroupLabelsQuery, querySpy],
    ]);


  wrapper = mount(LabelToken, {
      localVue,
      apolloProvider: mockApollo,
      provide: {
        portalName: 'fake',
        alignSuggestions: () => {},
        suggestionsListClass: () => {}
      },
      propsData: {
        config: { fullPath: '' },
        value: { data: 'first label' },
        active,
      },
      stubs: {
        Portal: true,
      }
    });

      await wrapper.vm.$nextTick();
      jest.runOnlyPendingTimers();
  }

  afterEach(() => {
    querySpy.mockRestore();
    wrapper.destroy();
    wrapper = null;
  })

  describe('default', () => {
    it('renders GlFilteredSearchToken', async () => {
      await createComponentWithApollo();

      expect(wrapper.find(GlFilteredSearchToken).exists()).toBe(true)
    });

    it('renders GlToken with the correct text', async () => {
      await createComponentWithApollo();

      await waitForPromises();

      expect(wrapper.find('[data-testid="label-token"]').text()).toBe('~first label')
    });

    it('renders GlFilteredSuggestion for every label', async () => {
      await createComponentWithApollo(true);

      await waitForPromises();

      wrapper.findAll(GlFilteredSearchTokenSegment).at(2).vm.$emit('activate');

      await waitForPromises();

      wrapper.findAll(GlFilteredSearchSuggestion).wrappers.forEach((w, idx) => {
        expect(w.text()).toContain(labels[idx].node.title);
        expect(w.find('[data-testid="token-background-color"]').element.style.backgroundColor).toContain(labels[idx].node.color)
      });

    });
  });

  describe('when searching', () => {
    it('calls the query with updated values', async () => {
      await createComponentWithApollo();

      wrapper.find(GlFilteredSearchToken).vm.$emit('input', { data: 'test' })

      await wrapper.vm.$nextTick();
      jest.runOnlyPendingTimers();

      expect(querySpy).toHaveBeenCalledWith({ fullPath: '', search: 'test' });
    });
  });
});
