import { shallowMount } from '@vue/test-utils';
import DynamicFields from 'ee/security_configuration/sast/components/dynamic_fields.vue';
import { makeEntities } from './helpers';

describe('DynamicFields component', () => {
  let wrapper;

  const createComponent = (props = {}) => {
    wrapper = shallowMount(DynamicFields, {
      propsData: {
        ...props,
      },
    });
  };

  const findFields = () => wrapper.findAll({ ref: 'fields' });

  afterEach(() => {
    wrapper.destroy();
    wrapper = null;
  });

  describe.each`
    context                                     | entities
    ${'no entities'}                            | ${[]}
    ${'entities with unsupported entity types'} | ${makeEntities(3, { type: 'foo' })}
  `('given $context', ({ entities }) => {
    beforeEach(() => {
      createComponent({ entities });
    });

    it('renders no fields', () => {
      expect(findFields()).toHaveLength(0);
    });
  });

  describe('given valid entities', () => {
    let entities;
    let fields;

    beforeEach(() => {
      entities = makeEntities(3);
      createComponent({ entities });
      fields = findFields();
    });

    it('renders each field with the correct component', () => {
      entities.forEach((entity, i) => {
        const field = fields.at(i);
        expect(field).toBeVueInstanceOf(DynamicFields.entityTypeToComponent[entity.type]);
      });
    });

    it('passes the correct props to each field', () => {
      entities.forEach((entity, i) => {
        const field = fields.at(i);

        expect(field.props()).toMatchObject({
          field: entity.field,
          label: entity.label,
          description: entity.description,
          defaultValue: entity.defaultValue,
          value: entity.value,
        });
      });
    });

    describe.each`
      fieldIndex | newValue
      ${0}       | ${'foo'}
      ${1}       | ${'bar'}
      ${2}       | ${'qux'}
    `(
      'when a field at index $fieldIndex emits an input event value $newValue',
      ({ fieldIndex, newValue }) => {
        beforeEach(() => {
          fields.at(fieldIndex).vm.$emit('input', newValue);
        });

        it('emits an input event with the correct entity value changed', () => {
          const [[payload]] = wrapper.emitted('input');

          entities.forEach((entity, i) => {
            if (i === fieldIndex) {
              const expectedChangedEntity = {
                ...entities[fieldIndex],
                value: newValue,
              };

              expect(payload[i]).not.toBe(entities[i]);
              expect(payload[i]).toEqual(expectedChangedEntity);
            } else {
              expect(payload[i]).toBe(entities[i]);
            }
          });
        });
      },
    );
  });
});
