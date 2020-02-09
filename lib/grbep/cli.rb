module Grbep
  class CLI
    def initialize(argv)
      @argv = argv
    end

    def run
      pattern, paths = parse_argv
      matcher = Matcher::Builder.build(pattern)
      paths.each do |path|
        content = File.read(path)
        tree = Parser::CurrentRuby.parse(content)
        next unless tree

        Grbep.traverse(tree) do |node|
          next unless matcher === node

          puts format(path: path, node: node)
        end
      end
    end

    private def parse_argv
      pattern = @argv[0]
      paths = @argv[1..-1]
      return pattern, paths
    end

    private def format(path:, node:)
      line = node.loc.line
      column = node.loc.column
      last_line = node.loc.last_line
      last_column = node.loc.last_column
      range = node.loc.expression
      source_line = range.source_buffer.source_line(line)

      head = source_line[0...column]
      if line == last_line
        matched = source_line[column...last_column]
        tail = source_line[last_column..-1]
      else
        matched = source_line[column..-1]
        tail = ''
      end

      "#{path}:#{line}:#{column+1}:#{head}#{red(matched)}#{tail}"
    end

    private def red(str)
      "\x1b[1;31m#{str}\x1b[0m"
    end
  end
end
