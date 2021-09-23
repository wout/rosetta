require "./parser"

begin
  parser_config = Rosetta::Parser::Config.from_yaml(ARGV[0])

  puts Rosetta::Parser.new(parser_config).parse!
rescue e : Exception
  puts e
end
