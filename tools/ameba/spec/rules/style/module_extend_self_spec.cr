require "../../spec_helper"

module Ameba::Rule::Style
  describe ModuleExtendSelf do
    subject = ModuleExtendSelf.new

    it "Passes when a module uses extend self" do
      expect_no_issues subject, <<-CRYSTAL
        module Foo
          extend self

          def bar
          end
        end
        CRYSTAL
    end

    it "Passes when a module has instance methods" do
      expect_no_issues subject, <<-CRYSTAL
        module Foo
          def self.bar
          end

          def baz
          end
        end
        CRYSTAL
    end

    it "Passes when a module has no methods" do
      expect_no_issues subject, <<-CRYSTAL
        module Foo
          BAR = 1
        end
        CRYSTAL
    end

    it "Ignores classes and structs" do
      expect_no_issues subject, <<-CRYSTAL
        class Foo
          def self.bar
          end
        end

        struct Baz
          def self.qux
          end
        end
        CRYSTAL
    end

    it "Reports and corrects a module that only defines methods on self" do
      source = expect_issue subject, <<-CRYSTAL
        module Foo
        # ^^^^^^^^ error: Use `extend self` instead of defining methods on `self`
          BAR = 1

          def self.bar : Int32
            baz
          end

          private def self.baz : Int32
            BAR
          end
        end
        CRYSTAL

      expect_correction source, <<-CRYSTAL
        module Foo
          extend self

          BAR = 1

          def bar : Int32
            baz
          end

          private def baz : Int32
            BAR
          end
        end
        CRYSTAL
    end

    it "Corrects nested modules with the right indentation" do
      source = expect_issue subject, <<-CRYSTAL
        module Foo
          module Bar
        # ^^^^^^^^^^ error: Use `extend self` instead of defining methods on `self`
            def self.baz
            end
          end
        end
        CRYSTAL

      expect_correction source, <<-CRYSTAL
        module Foo
          module Bar
            extend self

            def baz
            end
          end
        end
        CRYSTAL
    end

    it "Doesn't add a second extend self" do
      source = expect_issue subject, <<-CRYSTAL
        module Foo
        # ^^^^^^^^ error: Use `extend self` instead of defining methods on `self`
          extend self

          def self.bar
          end
        end
        CRYSTAL

      expect_correction source, <<-CRYSTAL
        module Foo
          extend self

          def bar
          end
        end
        CRYSTAL
    end
  end
end
