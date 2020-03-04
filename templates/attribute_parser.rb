require 'json'

def loop_hash(hash, keys = [], &block)
  hash.each do |k, v|
    if v.is_a?(Hash)
      loop_hash(v, keys.push(k), &block)
      keys.pop
    elsif block
      p = keys << k
      yield(p.clone, v)
      keys.pop
    end
  end
end

data = JSON.parse(ARGV[0])

mode = if data.key?('override_attributes')
         'override_attributes'
       elsif data.key?('default_attributes')
         'default_attributes'
       else
         raise 'not valid data'
       end

loop_hash(data[mode]) do |k, v|
  if /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RbConfig::CONFIG["host_os"]
    puts "#{mode.include?('override') ? 'override' : 'default'}#{k.map { |x| "['#{x}']" }.join()} = #{v.is_a?(String) ? "'#{v}'" : v}~~~"
  else
    puts "#{mode.include?('override') ? 'override' : 'default'}#{k.map { |x| "['#{x}']" }.join()} = #{v.is_a?(String) ? "'#{v}'" : v}"
  end
end
