import { GlFormInput, GlButton } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import Component from 'ee/registrations/components/invite_teammates.vue';

describe('User invites', () => {
  let wrapper;

  const createComponent = propsData => {
    wrapper = shallowMount(Component, {
      propsData,
    });
  };

  beforeEach(() => {
    createComponent({ emails: [] });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const inputs = () => wrapper.findAll(GlFormInput);
  const clickButton = () => wrapper.find(GlButton).vm.$emit('click');

  describe('Default state', () => {
    it('creates 2 input fields', () => {
      expect(inputs().length).toBe(2);
    });

    it.each([0, 1])('does not set a value', index => {
      expect(
        inputs()
          .at(index)
          .attributes('value'),
      ).toBe(undefined);
    });
  });

  describe('With already filled emails', () => {
    const emails = ['a@a', 'b@b', 'c@c'];

    beforeEach(() => {
      createComponent({ emails });
    });

    it('creates 3 input fields', () => {
      expect(inputs().length).toBe(3);
    });

    it.each([0, 1, 2])('restores the value of the passed emails', index => {
      expect(
        inputs()
          .at(index)
          .attributes('value'),
      ).toBe(emails[index]);
    });
  });

  describe('Adding an input', () => {
    beforeEach(() => {
      wrapper = mount(Component, {
        propsData: { emails: [] },
        attachToDocument: true,
      });

      clickButton();
    });

    it('adds an input field', () => {
      expect(inputs().length).toBe(3);
    });

    it.each([0, 1, 2])('does not set a value', index => {
      expect(
        inputs()
          .at(index)
          .attributes('value'),
      ).toBe(undefined);
    });

    it('sets the focus to the new input field', () => {
      expect(inputs().at(2).element).toBe(document.activeElement);
    });
  });
});
