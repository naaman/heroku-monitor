class LogOpts
  def initialize(opts={})
    @vals = opts
  end

  def ps(process_name)
    new_opt({"ps" => process_name})
  end
  
  def source(source_name)
    new_opt({"source" => source_name})
  end

  def tail
    return new_opt({"tail" => 1})
  end

  def num(number_of_lines)
    new_opt({"num" => number_of_lines})
  end
  
  def new_opt(val={})
    LogOpts.new(@vals.merge(val))
  end

  def to_opts
    @vals.map{|k,v| "#{k}=#{v}"}
  end

end
