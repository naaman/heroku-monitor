require "heroku/command"
require "monitor/logopts"

ProcessData = Struct.new(:process, :data)
DataPoint = Struct.new(:name, :value, :units)
  
class Heroku::Command::Monitor < Heroku::Command::BaseWithApp

  # monitor
  #
  # monitor your app
  # 
  # -p, --ps PS # only show metrics for this process
  def index
    monitor
  end

  # monitor
  # 
  # monitor your app
  # 
  # -p, --ps PS # only show metrics for this process
  def monitor
    log_opts = LogOpts.new.num(10000).tail
    log_opts = log_opts.ps(options[:ps]) if options[:ps]
    
    process_data = {}
    lines = 1
    
    heroku.read_logs(app, log_opts.to_opts) do |line|
      line.split(/\n/).each do |real_line|
        merge_data_from_line(real_line, process_data)
      end
      metrics_table(process_data)
    end
  end

  private

  def metrics_table(process_data)
    metrics_table = [["Metric","Median","P75","P95","P99"]]
    process_data.sort.each do |process_name, process_data|
      metrics_table << ["#{'-'*3}#{process_name}#{'-'*3}", '-'*10, '-'*10, '-'*10, '-'*10]
      process_data.sort.each do |measure_name, measure_data|
        metrics_table.push quantiles(measure_data).unshift("#{process_name}.#{measure_name}")
      end
    end
    appendage = metrics_table.size < 2 ? "\033[K" : ""
    print "\033[#{metrics_table.size}J\033[#{metrics_table.size}A#{appendage}"
    print_table metrics_table
  end
  
  def merge_data_from_line(line, data)
    parsed = parse(line)
    
    unless parsed.nil?
      if data[parsed.process].nil? then
        data[parsed.process] = {parsed.data.name => [parsed.data.value]}
      elsif data[parsed.process][parsed.data.name].nil?
        data[parsed.process][parsed.data.name] = [parsed.data.value]
      else
        data[parsed.process][parsed.data.name] << parsed.data.value
      end
    end
  end
  
  def quantiles(ary, quants=[0.5,0.75,0.95,0.99])
    d = ary.sort
    quants.sort.map{|q| d[(d.length * q).ceil - 1]}
  end

  def line_matcher(line)
    line.match(/(\S+)\s(\w+)\[(\w|.+)\]\:\s(.*)/)
  end
  
  def key_value_split(line)
    line.split(/(\S+=(?:\"[^\"]*\"|\S+))\s?/)
  end

  def parse(line)
    line_parts = line_matcher(line)
    return if line_parts.nil? || line_parts.length < 5

    process_name = line_parts[3]
    measures = key_value_split(line_parts[4])
                 .select{|v| !v.empty?}
                 .inject({}, &to_key_value)
                 .select{|k,v| k =~ /measure|val|units/}
    return if measures.empty? || measures.size < 2

    ProcessData.new(
      process_name, 
      DataPoint.new(
        measures["measure"], 
        measures["val"], 
        measures["units"]
      )
    )
  end

  def to_key_value
    lambda { |r, v|
      kv = v.split("=", 2)
      r[kv.first] = kv.last if kv.size == 2
      r
    }
  end

  def println(s)
    print("#{s}\n")
  end

  def print(s)
    $stdout.print s.gsub("\n", "\n\033[K")
  end

  def print_table(a)
    a
    .transpose
    .map.with_index{|col, i|
      w = col.map{|cell| cell.to_s.length}.max   # w = "column width" #
      col.map.with_index{|cell, i|
        i.zero?? cell.to_s.center(w) : cell.to_s.ljust(w)}   # alligns the column #
    }
    .transpose
    .each{|row| println "[#{row.join(' | ')}]"}
  end
end
