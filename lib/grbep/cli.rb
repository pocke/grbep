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

          puts "#{path}:#{node}"
        end
      end
    end

    private def parse_argv
      pattern = @argv[0]
      paths = @argv[1..-1]
      return pattern, paths
    end

  end
end
