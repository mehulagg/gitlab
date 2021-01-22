import { GlFormInput, GlButton } from '@gitlab/ui';
import { shallowMount, mount } from '@vue/test-utils';
import Component from 'ee/groups/components/invite_members.vue';

describe('User invites', () => {
  let wrapper;

  const createComponent = (propsData) => {
    wrapper = shallowMount(Component, {
      propsData,
    });
  };

  beforeEach(() => {
    createComponent({ emails: [], docsPath: 'https://some.doc.path' });
  });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  const inputs = () => wrapper.findAll(GlFormInput);
  const clickButton = () => wrapper.find(GlButton).vm.$emit('click');

  describe('Default state', () => {
    it('creates input field', () => {
      expect(inputs().length).toBe(1);
    });

    it('does not set a value', () => {
      expect(inputs().at(0).attributes('value')).toBe(undefined);
    });
  });

  describe('With already filled emails', () => {
    const emails = ['a@a', 'b@b', 'c@c'];

    beforeEach(() => {
      createComponent({ emails, docsPath: 'https://some.doc.path' });
    });

    it('creates 3 input fields', () => {
      expect(inputs().length).toBe(3);
    });

    it.each([0, 1, 2])('restores the value of the passed emails', (index) => {
      expect(inputs().at(index).attributes('value')).toBe(emails[index]);
    });
  });

  describe('Adding an input', () => {
    beforeEach(() => {
      wrapper = mount(Component, {
        propsData: { emails: [], docsPath: 'https://some.doc.path' },
        attachTo: document.body,
      });

      clickButton();
    });

    it('adds an input field', () => {
      expect(inputs().length).toBe(2);
    });

    it.each([0, 1])('does not set a value', (index) => {
      expect(inputs().at(index).attributes('value')).toBe(undefined);
    });

    it('sets the focus to the new input field', () => {
      expect(inputs().at(1).element).toBe(document.activeElement);
    });
  });
});
