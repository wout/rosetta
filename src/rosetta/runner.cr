require "./parser"

if ARGV.size == 3
  puts Rosetta::Parser.new(
    path: ARGV[0].to_s,
    default_locale: ARGV[1].to_s,
    available_locales: ARGV[2].to_s.split(',')
  ).parse!
end
