require "ameba"

module Ameba::Rule::Style
  class ModuleExtendSelf < Base
    properties do
      description "Enforces `extend self` in modules that only define methods on `self`"
    end

    MSG = "Use `extend self` instead of defining methods on `self`"

    def test(source : Source, node : Crystal::ModuleDef) : Nil
      children = direct_children(node.body)
      definitions = children.select(Crystal::Def)
      return if definitions.empty?
      return unless definitions.all? { |definition| self_receiver?(definition) }

      issue_for(node.location, node.name.end_location, MSG) do |corrector|
        insert_extend_self(source, node, corrector) unless extends_self?(children)

        definitions.each do |definition|
          receiver = definition.receiver
          next unless (location = receiver.try(&.location)) && (end_location = receiver.try(&.end_location))

          corrector.remove(location, end_location.adjust(column_number: 1))
        end
      end
    end

    private def direct_children(body : Crystal::ASTNode) : Array(Crystal::ASTNode)
      nodes = body.is_a?(Crystal::Expressions) ? body.expressions : [body]
      nodes.map { |child| child.is_a?(Crystal::VisibilityModifier) ? child.exp : child }
    end

    private def self_receiver?(definition : Crystal::Def) : Bool
      receiver = definition.receiver
      receiver.is_a?(Crystal::Var) && receiver.name == "self"
    end

    private def extends_self?(children : Array(Crystal::ASTNode)) : Bool
      children.any? do |child|
        child.is_a?(Crystal::Extend) && child.name.is_a?(Crystal::Self)
      end
    end

    private def insert_extend_self(source : Source, node : Crystal::ModuleDef, corrector : Source::Corrector) : Nil
      return unless location = node.location

      line_number = location.line_number
      line = source.lines[line_number - 1]
      indentation = " " * (location.column_number + 1)

      corrector.insert_after({line_number, line.size}, "\n#{indentation}extend self\n")
    end
  end
end
