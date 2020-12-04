import { languages } from 'monaco-editor';
import Api from '~/api/';

export default {
  registerCiSchema({ namespace, project, ref = 'master', path = '.gitlab-ci.yml' }) {
    // TODO This feature requires `schema_linting` feature flag
    const uri = Api.buildUrl(Api.projectFileSchemaPath)
      .replace(':namespace_path', namespace)
      .replace(':project_path', project)
      .replace(':ref', ref)
      .replace(':filename', path);

    console.log(uri);

    // TODO Possibly call registerSchema app/assets/javascripts/ide/utils.js instead
    languages.yaml.yamlDefaults.setDiagnosticsOptions({
      validate: true,
      enableSchemaRequest: true,
      hover: true,
      completion: true,
      schemas: [
        {
          uri,
          fileMatch: [`*${path}`],
        },
      ],
    });
  },
};
