require 'parser/current'

require "grbep/version"
require "grbep/cli"
require "grbep/matcher"

module Grbep
  class Error < StandardError; end
  # Your code goes here...

  def self.traverse(node, &block)
    block.call node
    node.children.each do |child|
      traverse(child, &block) if child.is_a?(Parser::AST::Node)
    end
  end
end
