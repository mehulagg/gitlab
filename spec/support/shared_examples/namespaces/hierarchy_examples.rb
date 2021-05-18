# frozen_string_literal: true

RSpec.shared_examples 'hierarchy with traversal_ids8' do
  # A convenient null node to represent the parent of root.
  let(:null_node) { double(traversal_ids8: []) }

  # Walk the tree to assert that the current_node's traversal_id is always
  # present and equal to it's parent's traversal_ids8 plus it's own ID.
  def validate_traversal_ids(current_node, parent = null_node)
    expect(current_node.traversal_ids8).to be_present
    expect(current_node.traversal_ids8).to eq parent.traversal_ids8 + [current_node.id]

    current_node.children.each do |child|
      validate_traversal_ids(child, current_node)
    end
  end

  it 'will be valid' do
    validate_traversal_ids(root)
  end
end
