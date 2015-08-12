Puppet::Parser::Functions::newfunction(:get_value, :type => :rvalue) do |args|
  value = nil
  args.each { |arg|
    if !arg.nil? and arg.to_s.length > 0
      value = arg
      break
    end
  }
  return value
end

