# frozen_string_literal: true

# TODO description
module RewriteContent
  def rewrite_content(content, source_parent, new_parent, current_user)
    return unless content

    rewriters = [Gitlab::Gfm::ReferenceRewriter, Gitlab::Gfm::UploadsRewriter]

    rewriters.inject(content) do |text, klass|
      rewriter = klass.new(text, source_parent, current_user)
      rewriter.rewrite(new_parent)
    end
  end
end
