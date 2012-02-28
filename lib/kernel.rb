# A patch to wirble would be better than the following... FYI.

module Kernel
  alias :pp_original :pp
  def_delegators :$terminal, :color

  def pp(*objs)
    if objs[0].class.ancestors[2] != Sequel::Model
      return pp_original(*objs) if objs[0].class != Array
      return pp_original(*objs) if objs[0].class == Array and objs[0].any? { |e| e.class.ancestors[2] != Sequel::Model }
    end

    # Now objs[0] is either a Sequel::Model, or an Array of all Sequel::Models.
    if objs[0].class != Array
      # objs[0] is a Sequel::Model
      return puts pp_sequel_model_helper(objs[0])
    end

    # Now objs[0] is an Array of 1 or more Sequel::Models
    ary_string = "["
    ary_string << objs[0].map { |model|
      pp_sequel_model_helper(model)
    }.join(', ')
    return puts (ary_string << "]")
  end

  def pp_sequel_model_helper(model)  
    string = model.inspect
    # Example: #<PaymentRequestItemUseTax @values={:useTaxId=>1385, :objectId=>"F52DAC30-BC69-F38F-2FE7-5157E5028529", :versionNumber=>3, :itemIdentifier=>1676, :rateCode=>"ARIZONAUSE", :taxAmount=>#<BigDecimal:8241140,'0.66E0',9(18)>, :chartOfAccountsCode=>"UA", :accountNumber=>"2892000", :financialObjectCode=>"9190"}>
    formatted = string =~ /(#\<[A-Za-z:]+) @values={(.*)}(\>)/
    return puts '*' + string unless formatted

    name = $1
    values = $2
    max_len = values.scan(/(:\w+)=\>(.+?)(?:, |$)/).map(&:first).sort_by(&:size).last.size
    join_string = $ppv ? ",\n" : ", "
    s2 = $ppv ? "#{color(name, :red)} #{color('@values', :blue)}={\n" : "#{color(name, :red)} #{color('@values', :blue)}={"
    s2 << values.scan(/(:\w+)=\>(.+?)(?:, |$)/).map { |match|
      kv = ''
      if $ppv
        case
        when match[0] =~ /^:/ then kv << "  #{color("%#{max_len}s" % [match[0]], :yellow)} => "
        else                       kv << "  %#{max_len}s => " % [match[0]]
        end
      else
        case
        when match[0] =~ /^:/ then kv << "#{color(match[0], :yellow)}=>"
        else                       kv << "#{match[0]}=>"
        end
      end

      case
      when match[1] =~ /^[0-9.]+$/ then kv << color(match[1], :cyan)
      when match[1] =~ /^".+"$/    then kv << color(match[1], :green)
      when match[1] =~ /^#\<BigDecimal:.+\>$/
        kv << (match[0] =~ /^:(\w+)/ ?
          color(model.send($1.to_sym).to_f.to_s, :cyan) :
          color(match[1], :magenta))
      when match[1] =~ /^#\<.+\>$/ then kv << color(match[1], :magenta)
      when match[1] =~ /^nil$/     then $ppnn ? kv=nil : kv << match[1]
      else                              kv << match[1]
      end
      kv
    }.compact.join(join_string)
    s2 << ($ppv ? "\n}#{color('>', :red)}" : "}#{color('>', :red)}")
    return s2
  end
end
