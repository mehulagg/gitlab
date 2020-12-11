import { ERROR_INSTANCE_REQUIRED_FOR_EXTENSION } from '~/editor/constants';
import { EditorLiteExtension } from '~/editor/editor_lite_extension_base';

describe('The basis for an Editor Lite extension', () => {
  const instance = {};
  let ext;

  it('accepts configuration options for an instance', () => {
    expect(instance.foo).toBeUndefined();
    ext = new EditorLiteExtension({ instance, foo: 'bar' });
    expect(ext.foo).toBeUndefined();
    expect(instance.foo).toBe('bar');
  });

  it('throws if only options are passed', () => {
    const consoleSpy = jest.spyOn(console, 'error').mockImplementation(() => {});
    expect(() => {
      ext = new EditorLiteExtension({ foo: 'bar' });
    }).toThrow(ERROR_INSTANCE_REQUIRED_FOR_EXTENSION);
    expect(consoleSpy).toHaveBeenCalledWith(ERROR_INSTANCE_REQUIRED_FOR_EXTENSION);
  });

  it('does not fail if both instance and the options are omitted', () => {
    expect(() => {
      ext = new EditorLiteExtension();
    }).not.toThrow();
  });
});
