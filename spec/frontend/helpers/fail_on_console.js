/* eslint-disable no-console */
import { ErrorWithStack } from 'jest-util';

const failOnConsole = method => {
  beforeEach(() => {
    jest.spyOn(console, method);
  });

  afterEach(() => {
    const callArgs = console[method].mock.calls[0];

    console[method].mockClear();

    if (callArgs) {
      throw new ErrorWithStack(
        `Unexpected call to console.${method}: ${callArgs.join(' ')}`,
        failOnConsole,
      );
    }
  });
};

export const failOnConsoleError = () => failOnConsole('error');

export const failOnConsoleWarn = () => failOnConsole('warn');
