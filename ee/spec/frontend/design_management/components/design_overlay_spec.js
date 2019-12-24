import { shallowMount } from '@vue/test-utils';
import DesignOverlay from 'ee/design_management/components/design_overlay.vue';

describe('Design overlay component', () => {
  let wrapper;

  const notes = [
    {
      position: {
        height: 100,
        width: 100,
        x: 10,
        y: 15,
      },
    },
    {
      position: {
        height: 50,
        width: 50,
        x: 25,
        y: 25,
      },
    },
  ];

  const findAllNotes = () => wrapper.findAll('.js-image-badge');
  const findCommentBadge = () => wrapper.find('.comment-indicator');
  const findFirstBadge = () => findAllNotes().at(0);
  const findSecondBadge = () => findAllNotes().at(1);

  function createComponent(props = {}) {
    wrapper = shallowMount(DesignOverlay, {
      sync: false,
      propsData: {
        position: {
          width: 100,
          height: 100,
        },
        ...props,
      },
    });
  }

  it('should have correct inline style', () => {
    createComponent();

    expect(wrapper.find('.image-diff-overlay').attributes().style).toBe(
      'width: 100px; height: 100px;',
    );
  });

  it('should emit a correct event when clicking on overlay', () => {
    createComponent();
    wrapper.find('.image-diff-overlay-add-comment').trigger('click', { offsetX: 10, offsetY: 10 });

    return wrapper.vm.$nextTick().then(() => {
      expect(wrapper.emitted('openCommentForm')).toEqual([[{ x: 10, y: 10 }]]);
    });
  });

  describe('when has notes', () => {
    beforeEach(() => {
      createComponent({
        notes,
      });
    });

    it('should render a correct amount of notes', () => {
      expect(findAllNotes().length).toBe(notes.length);
    });

    it('should have a correct style for each note badge', () => {
      expect(findFirstBadge().attributes().style).toBe('left: 10px; top: 15px;');

      expect(findSecondBadge().attributes().style).toBe('left: 50px; top: 50px;');
    });
  });

  it('should render a new comment badge when there is a new form', () => {
    createComponent({
      currentCommentForm: {
        height: 100,
        width: 100,
        x: 25,
        y: 25,
      },
    });

    expect(findCommentBadge().exists()).toBe(true);
    expect(findCommentBadge().attributes().style).toBe('left: 25px; top: 25px;');
  });

  it('should recalculate badges positions on window resize', () => {
    createComponent({
      notes,
      position: {
        width: 400,
        height: 400,
      },
    });

    expect(findFirstBadge().attributes().style).toBe('left: 40px; top: 60px;');

    wrapper.setProps({
      position: {
        width: 200,
        height: 200,
      },
    });

    return wrapper.vm.$nextTick().then(() => {
      expect(findFirstBadge().attributes().style).toBe('left: 20px; top: 30px;');
    });
  });
});
