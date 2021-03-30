# frozen_string_literal: true

namespace :gitlab do
  namespace :ci_templates do
    namespace :metadata do
      task generate: :environment do
        Gitlab::Template::GitlabCiYmlTemplate.all(ignore_category: true).each do |template|
          next if template.metadata.exist?

          placeholder = Gitlab::Template::GitlabCiYmlTemplate::Metadata
            .placeholder(name: template.full_name)

          new_content = placeholder + File.read(template.path)
          File.write(template.path, new_content)
        end
      end
    end
  end
end
