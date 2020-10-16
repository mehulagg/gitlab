import { ApolloLink, Observable } from 'apollo-link';
import { parse } from 'graphql';

export class StartupJSLink extends ApolloLink {
  constructor() {
    super();
    this.startupCalls = new Map();
    this.parseStartupCalls(window.gl?.startup_graphql_calls || []);
  }

  // Extract operationNames from the queries and ensure that we can
  // match operationName => element from result array
  parseStartupCalls(calls) {
    calls.forEach(call => {
      const { query, variables, fetchCall } = call;
      const operationName = parse(query)?.definitions?.find(x => x.kind === 'OperationDefinition')
        ?.name?.value;

      if (operationName) {
        this.startupCalls.set(operationName, {
          variables,
          fetchCall,
        });
      }
    });
  }

  static noopRequest = (operation, forward) => forward(operation);

  disable() {
    this.request = StartupJSLink.noopRequest;
    this.startupCalls = null;
  }

  request(operation, forward) {
    // Disable StartupJSLink in case all calls are done or none are set up
    if (this.startupCalls && this.startupCalls.size === 0) {
      this.disable();
      return forward(operation);
    }

    const { operationName } = operation;

    // Skip startup call if the operationName doesn't match
    if (!this.startupCalls.has(operationName)) {
      return forward(operation);
    }

    const { variables: startupVariables, fetchCall } = this.startupCalls.get(operationName);
    this.startupCalls.delete(operationName);

    // Skip startup call if the variables values do not match
    const variables = Object.entries(operation.variables || {});
    for (let i = 0; i < variables.length; i += 1) {
      const [key, value] = variables[i];
      if (startupVariables[key] !== value) {
        return forward(operation);
      }
    }

    return new Observable(observer => {
      fetchCall
        .then(response => {
          // Handle HTTP errors
          if (!response.ok) {
            throw new Error('fetchCall failed');
          }
          operation.setContext({ response });
          return response.json();
        })
        .then(result => {
          // we have data and can send it to back up the link chain
          observer.next(result);
          observer.complete();
        })
        .catch(() => {
          forward(operation).subscribe({
            next: result => {
              observer.next(result);
            },
            error: error => {
              observer.error(error);
            },
            complete: observer.complete.bind(observer),
          });
        });
    });
  }
}
