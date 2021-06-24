module Gitlab
  module Purgecss
    class PurgecssTransformer < ::SassC::Rails::ScssTemplate
      def call(input)
        # TODO - Look at https://github.com/sass/sassc-rails/blob/8d0462d54b5b5dd84cb1df31823c3afaebb64534/lib/sassc/rails/template.rb#L43
        # we will likely need to hook into `context.metadata.merge(data: css)`
        puts "[purgecss_transformer] I'm here! Look at me!"
        puts "[purgecss_transformer] I'm here! Look at me!"
        puts "[purgecss_transformer] I'm here! Look at me!"
        puts "[purgecss_transformer] I'm here! Look at me!"
        puts "[purgecss_transformer] I'm here! Look at me!"
        puts "[purgecss_transformer] I'm here! Look at me!"
        puts "[purgecss_transformer] I'm here! Look at me!"
        super(input)
      end
    end
  end
end
