import {
  serializeForm,
  serializeFormObject,
  isEmptyValue,
  parseRailsFormFields,
} from '~/lib/utils/forms';

describe('lib/utils/forms', () => {
  const createDummyForm = (inputs) => {
    const form = document.createElement('form');

    form.innerHTML = inputs
      .map(({ type, name, value }) => {
        let str = ``;
        if (type === 'select') {
          str = `<select name="${name}">`;
          value.forEach((v) => {
            if (v.length > 0) {
              str += `<option value="${v}"></option> `;
            }
          });
          str += `</select>`;
        } else {
          str = `<input type="${type}" name="${name}" value="${value}" checked/>`;
        }
        return str;
      })
      .join('');

    return form;
  };

  describe('serializeForm', () => {
    it('returns an object of key values from inputs', () => {
      const form = createDummyForm([
        { type: 'text', name: 'foo', value: 'foo-value' },
        { type: 'text', name: 'bar', value: 'bar-value' },
      ]);

      const data = serializeForm(form);

      expect(data).toEqual({
        foo: 'foo-value',
        bar: 'bar-value',
      });
    });

    it('works with select', () => {
      const form = createDummyForm([
        { type: 'select', name: 'foo', value: ['foo-value1', 'foo-value2'] },
        { type: 'text', name: 'bar', value: 'bar-value1' },
      ]);

      const data = serializeForm(form);

      expect(data).toEqual({
        foo: 'foo-value1',
        bar: 'bar-value1',
      });
    });

    it('works with multiple inputs of the same name', () => {
      const form = createDummyForm([
        { type: 'checkbox', name: 'foo', value: 'foo-value3' },
        { type: 'checkbox', name: 'foo', value: 'foo-value2' },
        { type: 'checkbox', name: 'foo', value: 'foo-value1' },
        { type: 'text', name: 'bar', value: 'bar-value2' },
        { type: 'text', name: 'bar', value: 'bar-value1' },
      ]);

      const data = serializeForm(form);

      expect(data).toEqual({
        foo: ['foo-value3', 'foo-value2', 'foo-value1'],
        bar: ['bar-value2', 'bar-value1'],
      });
    });

    it('handles Microsoft Edge FormData.getAll() bug', () => {
      const formData = [
        { type: 'checkbox', name: 'foo', value: 'foo-value1' },
        { type: 'text', name: 'bar', value: 'bar-value2' },
      ];

      const form = createDummyForm(formData);

      jest
        .spyOn(FormData.prototype, 'getAll')
        .mockImplementation((name) =>
          formData.map((elem) => (elem.name === name ? elem.value : undefined)),
        );

      const data = serializeForm(form);

      expect(data).toEqual({
        foo: 'foo-value1',
        bar: 'bar-value2',
      });
    });
  });

  describe('isEmptyValue', () => {
    it.each`
      input        | returnValue
      ${''}        | ${true}
      ${[]}        | ${true}
      ${null}      | ${true}
      ${undefined} | ${true}
      ${'hello'}   | ${false}
      ${' '}       | ${false}
      ${0}         | ${false}
    `('returns $returnValue for value $input', ({ input, returnValue }) => {
      expect(isEmptyValue(input)).toBe(returnValue);
    });
  });

  describe('serializeFormObject', () => {
    it('returns an serialized object', () => {
      const form = {
        profileName: { value: 'hello', state: null, feedback: null },
        spiderTimeout: { value: 2, state: true, feedback: null },
        targetTimeout: { value: 12, state: true, feedback: null },
      };
      expect(serializeFormObject(form)).toEqual({
        profileName: 'hello',
        spiderTimeout: 2,
        targetTimeout: 12,
      });
    });

    it('returns only the entries with value', () => {
      const form = {
        profileName: { value: '', state: null, feedback: null },
        spiderTimeout: { value: 0, state: null, feedback: null },
        targetTimeout: { value: null, state: null, feedback: null },
        name: { value: undefined, state: null, feedback: null },
      };
      expect(serializeFormObject(form)).toEqual({
        spiderTimeout: 0,
      });
    });
  });

  describe('parseRailsFormFields', () => {
    const mountEl = document.createElement('div');
    mountEl.classList.add('js-foo-bar');
    mountEl.innerHTML = `
      <input class="form-control gl-form-input" type="text" placeholder="Name" value="Administrator" name="user[name]" id="user_name">
      <input class="form-control gl-form-input" type="email" placeholder="Email" value="admin@example.com" name="user[email]" id="user_email">
      <input class="form-control gl-form-input" type="hidden" placeholder="Job title" value="" name="user[job_title]" id="user_job_title">
      <textarea class="form-control gl-form-input" name="user[bio]" id="user_bio">Foo bar</textarea>
      <input type="checkbox" name="user[interests][]" id="user_interests_vue" value="Vue">
      <input type="checkbox" name="user[interests][]" id="user_interests_graphql" value="GraphQL">
      <input type="radio" name="user[access_level]" value="regular" id="user_access_level_regular">
      <input type="radio" name="user[access_level]" value="admin" id="user_access_level_admin">
    `;

    it('parses fields generated by Rails and returns object with HTML attributes', () => {
      expect(parseRailsFormFields(mountEl)).toEqual({
        name: {
          name: 'user[name]',
          id: 'user_name',
          value: 'Administrator',
          placeholder: 'Name',
        },
        email: {
          name: 'user[email]',
          id: 'user_email',
          value: 'admin@example.com',
          placeholder: 'Email',
        },
        jobTitle: {
          name: 'user[job_title]',
          id: 'user_job_title',
          value: '',
          placeholder: 'Job title',
        },
        bio: {
          name: 'user[bio]',
          id: 'user_bio',
          value: 'Foo bar',
        },
        interests: [
          {
            name: 'user[interests][]',
            id: 'user_interests_vue',
            value: 'Vue',
          },
          {
            name: 'user[interests][]',
            id: 'user_interests_graphql',
            value: 'GraphQL',
          },
        ],
        accessLevel: [
          {
            name: 'user[access_level]',
            id: 'user_access_level_regular',
            value: 'regular',
          },
          {
            name: 'user[access_level]',
            id: 'user_access_level_admin',
            value: 'admin',
          },
        ],
      });
    });
  });
});
