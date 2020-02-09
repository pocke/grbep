module Grbep
  module Matcher
    module Builder
      extend self

      def build(ruby_code)
        ast = Parser::CurrentRuby.parse(ruby_code)
        convert_to_matcher(ast)
      end

      private def convert_to_matcher(node)
        child0 = node.children[0]

        # `any`
        if node.type == :xstr && child0.type == :str && child0.children[0] == 'any'
          return Any.new
        end

        # vcall
        if node.type == :send && child0 == nil && node.children.size == 2 && !node.loc.end&.is?(')')
          return VcallOrLvar.new(node.children[1])
        end

        # other cases
        children = node.children.map do |child|
          if child.is_a?(Parser::AST::Node)
            convert_to_matcher(child)
          else
            child
          end
        end

        Generic.new(node.type, children)
      end
    end

    class Generic
      def initialize(type, children)
        @type = type
        @children = children
      end

      def ===(rhs)
        return false unless rhs.is_a?(Parser::AST::Node)

        @type == rhs.type &&
          @children.size == rhs.children.size &&
          @children.zip(rhs.children).all? { |m, r| m === r }
      end
    end

    class Any
      def ===(rhs) true end
    end

    class VcallOrLvar
      def initialize(name)
        @name = name
      end

      def ===(rhs)
        return false unless rhs.is_a?(Parser::AST::Node)

        case rhs.type
        when :send
          rhs.children.size == 2 &&
            rhs.children[0] == nil &&
            @name === rhs.children[1]
        when :lvar
          @name === rhs.children[0]
        else
          false
        end
      end
    end
  end
end
