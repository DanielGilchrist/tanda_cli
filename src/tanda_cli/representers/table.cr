require "./builder"
require "./table/column"
require "./table/row"
require "./table/summary"
require "../utils/terminal"

module TandaCLI
  module Representers
    struct Table
      GUTTER_WIDTH = 2
      CELL_GAP     = 2
      RESERVED     = 1

      def initialize(@columns : Array(Column)) : Nil
        @rows = Array(Row).new
        @summaries = Array(Summary).new
      end

      def <<(row : Row) : Nil
        @rows << row
      end

      def summarise(column : Int32, value : String, label : String) : Nil
        @summaries << Summary.new(column, value, label)
      end

      def build(builder : Builder, header : Bool = true) : Nil
        widths = self.widths

        heading = lines(header_cells, widths, gutter: ' ').first if header
        body = @rows.flat_map { |row| lines(row.cells, widths, gutter: row.gutter) }
        totals = @summaries.map { |summary| summary_line(summary, widths) }

        builder.puts(heading.colorize.white.bold) if heading
        body.each { |text| builder.puts(text) }

        return if totals.empty?

        builder.puts
        totals.each { |text| builder.puts(text) }
      end

      private def summary_line(summary : Summary, widths : Array(Int32)) : String
        column = summary.column
        offset = GUTTER_WIDTH + widths[0...column].sum + (CELL_GAP * column)

        "#{" " * offset}#{summary.value.rjust(widths[column])}#{" " * CELL_GAP}#{summary.label}".rstrip
      end

      private def header_cells : Array(String)
        @columns.map(&.name)
      end

      private def widths : Array(Int32)
        natural = @columns.map_with_index do |column, index|
          column.width_for(@rows.map(&.cell(index)) + summary_values(index))
        end

        last = natural.size - 1
        natural[last] = constrained_last_width(natural)

        natural
      end

      private def summary_values(column : Int32) : Array(String)
        @summaries.select(&.column.==(column)).map(&.value)
      end

      private def constrained_last_width(widths : Array(Int32)) : Int32
        last = widths.size - 1
        available = Utils::Terminal.width?
        return widths[last] unless available

        prefix = GUTTER_WIDTH + widths[0...last].sum + (CELL_GAP * last)
        remaining = available - prefix - RESERVED

        remaining < 1 ? widths[last] : {widths[last], remaining}.min
      end

      private def lines(cells : Array(String), widths : Array(Int32), gutter : Char) : Array(String)
        last = widths.size - 1

        fixed = @columns.first(last).map_with_index do |column, index|
          column.render(cells[index]? || "", widths[index])
        end

        prefix = "#{gutter} #{fixed.join(" " * CELL_GAP)}"
        prefix += " " * CELL_GAP unless fixed.empty?

        wrapped = wrap(cells[last]? || "", widths[last])
        indent = " " * prefix.size

        wrapped.map_with_index do |text, index|
          "#{index.zero? ? prefix : indent}#{text}".rstrip
        end
      end

      private def wrap(value : String, width : Int32) : Array(String)
        return [value] if value.size <= width || width < 1

        lines = [] of String
        current = String::Builder.new
        length = 0

        words(value, width).each do |word|
          if length.zero?
            current << word
            length = word.size
          elsif length + 1 + word.size <= width
            current << ' ' << word
            length += 1 + word.size
          else
            lines << current.to_s
            current = String::Builder.new
            current << word
            length = word.size
          end
        end

        lines << current.to_s
        lines
      end

      private def words(value : String, width : Int32) : Array(String)
        value.split(' ').flat_map do |word|
          word.size <= width ? [word] : chunk(word, width)
        end
      end

      private def chunk(word : String, width : Int32) : Array(String)
        pieces = [] of String
        index = 0

        while index < word.size
          pieces << word[index, width]
          index += width
        end

        pieces
      end
    end
  end
end
