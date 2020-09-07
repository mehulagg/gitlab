import { shallowMount, createLocalVue } from '@vue/test-utils';
import VueApollo from 'vue-apollo';
import VueRouter from 'vue-router';
import VueDraggable from 'vuedraggable';
import Design from '~/design_management/components/list/item.vue';
import createRouter from '~/design_management/router';
import getDesignListQuery from '~/design_management/graphql/queries/get_design_list.query.graphql';
import permissionsQuery from '~/design_management/graphql/queries/design_permissions.query.graphql';
import moveDesignMutation from '~/design_management/graphql/mutations/move_design.mutation.graphql';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import createMockApollo from '../../helpers/mock_apollo_helper';
import Index from '~/design_management/pages/index.vue';
import {
  designListQueryResponse,
  permissionsQueryResponse,
  moveDesignMutationResponse,
  reorderedDesigns,
  moveDesignMutationResponseWithErrors,
} from '../mock_data/apollo_mock';

jest.mock('~/flash');

const localVue = createLocalVue();
localVue.use(VueApollo);

const router = createRouter();
localVue.use(VueRouter);

const designToMove = {
  __typename: 'Design',
  id: '2',
  event: 'NONE',
  filename: 'fox_2.jpg',
  notesCount: 2,
  image: 'image-2',
  imageV432x230: 'image-2',
};

describe('Design management index page with Apollo mock', () => {
  let wrapper;
  let fakeApollo;
  let moveDesignHandler;

  async function moveDesigns(localWrapper) {
    await jest.runOnlyPendingTimers();
    await localWrapper.vm.$nextTick();

    localWrapper.find(VueDraggable).vm.$emit('input', reorderedDesigns);
    localWrapper.find(VueDraggable).vm.$emit('change', {
      moved: {
        newIndex: 0,
        element: designToMove,
      },
    });
  }

  const findDesigns = () => wrapper.findAll(Design);

  function createComponent({
    moveHandler = jest.fn().mockResolvedValue(moveDesignMutationResponse),
  }) {
    moveDesignHandler = moveHandler;

    const requestHandlers = [
      [getDesignListQuery, jest.fn().mockResolvedValue(designListQueryResponse)],
      [permissionsQuery, jest.fn().mockResolvedValue(permissionsQueryResponse)],
      [moveDesignMutation, moveDesignHandler],
    ];

    fakeApollo = createMockApollo(requestHandlers);
    wrapper = shallowMount(Index, {
      localVue,
      apolloProvider: fakeApollo,
      router,
      stubs: { VueDraggable },
    });
  }

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  it('has a design with id 1 as a first one', async () => {
    createComponent({});

    await jest.runOnlyPendingTimers();
    await wrapper.vm.$nextTick();

    expect(findDesigns()).toHaveLength(3);
    expect(
      findDesigns()
        .at(0)
        .props('id'),
    ).toBe('1');
  });

  it('calls a mutation with correct parameters and reorders designs', async () => {
    createComponent({});

    await moveDesigns(wrapper);

    expect(moveDesignHandler).toHaveBeenCalled();

    await wrapper.vm.$nextTick();

    expect(
      findDesigns()
        .at(0)
        .props('id'),
    ).toBe('2');
  });

  it('displays flash if mutation had a recoverable error', async () => {
    createComponent({
      moveHandler: jest.fn().mockResolvedValue(moveDesignMutationResponseWithErrors),
    });

    await moveDesigns(wrapper);

    await wrapper.vm.$nextTick();

    expect(createFlash).toHaveBeenCalledWith('Houston, we have a problem');
  });

  it('displays flash if mutation had a non-recoverable error', async () => {
    createComponent({
      moveHandler: jest.fn().mockRejectedValue('Error'),
    });

    await moveDesigns(wrapper);

    await wrapper.vm.$nextTick(); // kick off the DOM update
    await jest.runOnlyPendingTimers(); // kick off the mocked GQL stuff (promises)
    await wrapper.vm.$nextTick(); // kick off the DOM update for flash

    expect(createFlash).toHaveBeenCalledWith(
      'Something went wrong when reordering designs. Please try again',
    );
  });
});
