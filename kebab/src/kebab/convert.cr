require "./error/unparseable"

module Kebab
  module Convert
    extend self

    def parse(type : String.class, raw : String) : String | Error::Unparseable
      raw
    end

    {% for number_type, suffix in {
                                    Int8 => "i8", Int16 => "i16", Int32 => "i32", Int64 => "i64",
                                    UInt8 => "u8", UInt16 => "u16", UInt32 => "u32", UInt64 => "u64",
                                    Float32 => "f32", Float64 => "f64",
                                  } %}
      def parse(type : {{number_type}}.class, raw : String) : {{number_type}} | Error::Unparseable
        raw.to_{{suffix.id}}? || ::Kebab.parse_error("expected a number ({{number_type}})")
      end
    {% end %}

    def parse(type : T.class, raw : String) : T | Error::Unparseable forall T
      type.parse(raw)
    end
  end
end
