EVENT_FILE = "events.csv"
$pic = Array.new(8){|a| a = Array.new(53)}
$FREQ=1.848e9

open(EVENT_FILE){|f|
  while line = f.gets
    next if line=~/Encodeing/
    a = line.chomp.split(/,/)
    encoding = a[0].to_i
    (0..7).each{|i|
      $pic[i][encoding] = a[i+1]
    }
  end
}

class Hash
  def get_value(key)
    return 0.0/0 if !has_key?(key)
    self[key].to_f
  end
end

class Float
  def to_ss
    return " N/A" if nan?
    s = sprintf "%.5f",self
    s = s.rjust(7)
    return s[0..6]
  end
end

class ProfAnalyser
  def initialize
    @text_hash = Hash.new
    @max_process = 0
    @max_thread = 0
    @measured_events = Hash.new
    @data_hash = Hash.new
    @type = ""
  end

  def read_file(file)
    begin
      f = open(file)
    rescue
      puts "Fatal Error: Could not open " + file
      exit
    end
    current_process = "devnull"
    process = 0
    thread = 0
    @text_hash[current_process] = ""
    while line=f.gets
      if line=~/Type of program/
        line.gsub!(/\"/,"")
        a = line.split(",")
        @type = a[1]
      elsif line=~/CPU frequency.* ([0-9]+) \(MHz\)/
        $FREQ = $1.to_f * 1e6
        #puts "Hz = #{$1}"
      elsif line =~ /Application event-Internal/
        current_process = "default"
        @text_hash[current_process] = ""
      elsif line =~ /Procedures profile - Process ([0-9]+)/
        current_process = "process" + $1
        @text_hash[current_process] = ""
        process = $1.to_i
        if process > @max_process
          @max_process =  process
        end
      elsif line =~ /Procedures profile - Thread ([0-9]+)/
        current_process = "process" + process.to_s + " thread" + $1
        @text_hash[current_process] = ""
        thread = $1.to_i
        if thread > @max_thread
          @max_thread =  thread
        end
 
      end
      @text_hash[current_process] = @text_hash[current_process] + line
    end
    @text_hash.each_key{|key|
      if key != "devnull"
        parse(key)
      end
    }
  end

  def parse(current_process)
    if !@data_hash.key?(current_process)
      @data_hash[current_process] = Hash.new
    end
    rangecount = -1 
    e_pic = Array.new(8)
    text = @text_hash[current_process]
    text.split("\n").each{|line|
      if line =~ /Performance monitor/
        next
      end
      line.gsub!(/\"/,"")
      a = line.split(",")
      if a[0] == "Range"
        rangecount = rangecount + 1
        (0..3).each{|i|
          j = i + rangecount*4
          event = $pic[j][a[i+1].to_i]
          e_pic[j] = event
          @measured_events[event] = j
        }
      else
        range = a[0]
        if !@data_hash[current_process].key?(range)
          @data_hash[current_process][range] = Hash.new
        end
        (0..3).each{|i|
          j = i + rangecount*4
          event = e_pic[j]
          @data_hash[current_process][range][event] = a[i+1].to_i 
        }
      end
    } 
  end 

  def get_elapsed(h)
    cycle = h.get_value("cycle_counts")
    cycle / ($FREQ);
  end
 
  def get_mflops(h)
    cycle = h.get_value("cycle_counts")
    fi = h.get_value("floating_instructions")
    fma = h.get_value("fma_instructions")
    s_fi = h.get_value("SIMD_floating_instructions")
    s_fma = h.get_value("SIMD_fma_instructions")
    (fi+fma*2+s_fi*2+s_fma*4)/(cycle)*$FREQ*1e-6
  end

  def get_mips(h)
    cycle = h.get_value("cycle_counts")
    inst = h.get_value("effective_instruction_counts")
    inst/cycle*$FREQ*1e-6
  end

  def get_peak(h)
    cycle = h.get_value("cycle_counts")
    fi = h.get_value("floating_instructions")
    fma = h.get_value("fma_instructions")
    s_fi = h.get_value("SIMD_floating_instructions")
    s_fma = h.get_value("SIMD_fma_instructions")
    value = (fi+fma*2+s_fi*2+s_fma*4)/(cycle*8)*100.0
  end

  def get_memthru(h)
    cycle = h.get_value("cycle_counts")
    ex_l = h.get_value("ex_load_instructions")
    ex_s = h.get_value("ex_store_instructions")
    fl_l = h.get_value("fl_load_instructions")
    fl_s = h.get_value("fl_store_instructions")
    ex_l = ex_l * get_imemwait(h)
    fl_l = fl_l * get_flmemwait(h)
    t = get_elapsed(h)
    ((ex_l+ex_s)*4+(fl_l+fl_s)*8)/t*1e-9
  end

  def get_mtlbmiss(h)
    simd_load_store = h.get_value("SIMD_load_store_instructions")
    load_store = h.get_value("load_store_instructions")
    dmmu_miss= h.get_value("trap_DMMU_miss")
    dmmu_miss/(load_store + simd_load_store*2)*100
  end

  def get_utlbmiss(h)
    simd_load_store = h.get_value("SIMD_load_store_instructions")
    load_store = h.get_value("load_store_instructions")
    udtlb_miss= h.get_value("uDTLB_miss")
    udtlb_miss/(load_store + simd_load_store*2)*100
  end

  def get_l1dmiss(h)
    simd_load_store = h.get_value("SIMD_load_store_instructions")
    load_store = h.get_value("load_store_instructions")
    l1dmiss = h.get_value("L1D_miss")
    l1dmiss/(load_store+simd_load_store*2)*100
  end

  def get_l2miss(h)
    simd_load_store = h.get_value("SIMD_load_store_instructions")
    load_store = h.get_value("load_store_instructions")
    l2_miss_dm = h.get_value("L2_miss_dm")
    l2_miss_pf = h.get_value("L2_miss_pf")
    (l2_miss_dm+l2_miss_pf)/(simd_load_store*2 + load_store)*100
  end

  def get_simd_f(h) 
    all = h.get_value("effective_instruction_counts")
    s_fi = h.get_value("SIMD_floating_instructions")
    (s_fi)/all*100
  end

  def get_fma(h) 
    all = h.get_value("effective_instruction_counts")
    fma = h.get_value("fma_instructions")
    (fma)/all*100
  end

 def get_simd_fma(h) 
    all = h.get_value("effective_instruction_counts")
    s_fma = h.get_value("SIMD_fma_instructions")
    (s_fma)/all*100
  end

  def get_f(h) 
    all = h.get_value("effective_instruction_counts")
    fi = h.get_value("floating_instructions")
    fi/all*100
  end

  def get_inst_wait(h) 
    cycle = h.get_value("cycle_counts")
    cse = h.get_value("cse_window_empty")
    cse_sp = h.get_value("cse_window_empty_sp_full")
    sleep = h.get_value("sleep_cycle")
     (cse - cse_sp-sleep)/cycle*100
  end

  def get_branch_wait(h) 
    cycle = h.get_value("cycle_counts")
    branch = h.get_value("branch_comp_wait")
    branch/cycle*100
  end

  def get_barrier(h) 
    cycle = h.get_value("cycle_counts")
    sleep = h.get_value("sleep_cycle")
    sleep/cycle*100
  end

  def get_fl_wait(h)
    cycle = h.get_value("cycle_counts")
    fl_comp_wait = h.get_value("fl_comp_wait")
    fl_comp_wait/cycle*100
  end

  def get_int_wait(h)
    cycle = h.get_value("cycle_counts")
    fl_comp_wait = h.get_value("fl_comp_wait")
    eu_comp_wait = h.get_value("eu_comp_wait")
    (eu_comp_wait - fl_comp_wait)/cycle*100
  end

  def get_imemwait(h)
    cycle = h.get_value("cycle_counts")
    l2wait = h.get_value("op_stv_wait_sxmiss_ex")
    l2wait/cycle*100
  end

  def get_icachewait(h)
    cycle = h.get_value("cycle_counts")
    wait = h.get_value("op_stv_wait_ex")
    l2wait = h.get_value("op_stv_wait_sxmiss_ex")
    (wait-l2wait)/cycle*100
  end

  def get_flcachewait(h)
    cycle = h.get_value("cycle_counts")
    wait = h.get_value("op_stv_wait")
    intwait = h.get_value("op_stv_wait_ex")
    l2wait = h.get_value("op_stv_wait_sxmiss")
    intl2wait = h.get_value("op_stv_wait_sxmiss_ex")
    (wait - l2wait - intwait + intl2wait)/cycle*100
  end

  def get_flmemwait(h)
    cycle = h.get_value("cycle_counts")
    wait = h.get_value("op_stv_wait")
    intwait = h.get_value("op_stv_wait_ex")
    l2wait = h.get_value("op_stv_wait_sxmiss")
    intl2wait = h.get_value("op_stv_wait_sxmiss_ex")
    (l2wait - intl2wait)/cycle*100
  end

  def get_0endop(h)
    cycle = h.get_value("cycle_counts")
    endop0 = h.get_value("0endop")
    endop0/cycle*100
  end

  def get_1endop(h)
    cycle = h.get_value("cycle_counts")
    endop1 = h.get_value("1endop")
    endop1/cycle*100
  end

  def get_2endop(h)
    cycle = h.get_value("cycle_counts")
    endop2 = h.get_value("2endop")
    endop2/cycle*100
  end

  def get_3endop(h)
    cycle = h.get_value("cycle_counts")
    endop3 = h.get_value("3endop")
    endop3/cycle*100
  end

  def get_gprwait(h)
    cycle = h.get_value("cycle_counts")
    inh = h.get_value("inh_cmit_gpr_2write")
    inh/cycle*100
  end

  def get_4endop(h)
    cycle = h.get_value("cycle_counts")
    endop0 = h.get_value("0endop")
    endop1 = h.get_value("1endop")
    endop2 = h.get_value("2endop")
    endop3 = h.get_value("3endop")
    (cycle - endop0 - endop1 - endop2 - endop3)/cycle*100
  end

  
  def get_ipc(h)
    cycle = h.get_value("cycle_counts")
    all = h.get_value("effective_instruction_counts")
    all/cycle 
  end

  def putsheader(a)
    str = ""
    a.each{|key|
      if key.length < 7
        str = str + key.ljust(7) + " "
      else
        str = str + key + " "
      end 
    }
    puts str
  end

  def putsvalues(a,h)
    str = ""
    a.each{|key|
      value = ""
      if key == "Measured Range"
        value = h[key]
      else
        value = h[key].to_ss
      end
      if key.length > 7
        str = str + value.ljust(key.length) + " "
      else
        str = str + value.ljust(7) + " "
      end
    }
    puts str
  end

  def calcprocess(current_process)
    if !@data_hash.has_key?(current_process)
      puts
      puts "Fatal Error: Could not find profile of " + current_process
      puts "CSV file may be incomplete."
      puts
      exit 
    end
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      h["Measured Range"] = range
      h["ELAPSED"] = get_elapsed(h)
      h["MFLOPS"] = get_mflops(h)
      h["PEAK(%)"] = get_peak(h)
      h["MIPS"] = get_mips(h)
      h["MEMTHRU(GB/s)"] = get_memthru(h)
      h["FLOAT(%)"] = get_f(h)
      h["FMA(%)"] = get_fma(h)
      h["SIMD(%)"] = get_simd_f(h)
      h["SIMD-FMA(%)"] = get_simd_fma(h)
      h["L1DMISS(%)"] = get_l1dmiss(h)
      h["L2MISS(%)"] = get_l2miss(h)
      h["MTLBMISS(%)"] = get_mtlbmiss(h)
      h["UTLBMISS(%)"] = get_utlbmiss(h)
      h["BARRIER(%)"] = get_barrier(h)
      h["INTWAIT(%)"] =  get_int_wait(h)
      h["FLWAIT(%)"] = get_fl_wait(h)
      h["BRWAIT(%)"] = get_branch_wait(h)
      h["IMEMWAIT(%)"] = get_imemwait(h)
      h["ICACHEWAIT(%)"] = get_icachewait(h)
      h["FLMEMWAIT(%)"] = get_flmemwait(h)
      h["FLCACHEWAIT(%)"] = get_flcachewait(h)
      h["INSTFETCH(%)"] = get_inst_wait(h)
      h["0ENDOP(%)"] = get_0endop(h)
      h["1ENDOP(%)"] = get_1endop(h)
      h["2/3ENDOP(%)"] = get_2endop(h) + get_3endop(h) - get_gprwait(h)
      h["GPRWAIT(%)"] = get_gprwait(h)
      h["4ENDOP(%)"] = get_4endop(h)
      h["IPC"] = get_ipc(h)
    }
  end

  def showprocess(current_process)
    if !@data_hash.has_key?(current_process)
      puts
      puts "Fatal Error: Could not find profile of " + current_process
      puts "CSV file may be incomplete."
      puts
      exit 
    end
    putline 
    puts current_process
    puts "#### Performance Information ####"
    keys =  ["Measured Range","ELAPSED","MFLOPS","PEAK(%)","MIPS"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }

    puts 
    puts "#### SIMD Information ####"
    keys= ["Measured Range","SIMD(%)","FLOAT(%)","SIMD-FMA(%)","FMA(%)"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }

    puts
    puts "#### Cache Information ####"
    keys= ["Measured Range","L1DMISS(%)","L2MISS(%)","MTLBMISS(%)","UTLBMISS(%)"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }

    puts
    puts "#### Wait Information (Instruction) ####"
    keys= ["Measured Range","BARRIER(%)","INTWAIT(%)","FLWAIT(%)","BRWAIT(%)","INSTFETCH(%)"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }

    puts
    puts "#### Wait Information (Memory/Cache) ####"
    keys= ["Measured Range","IMEMWAIT(%)","ICACHEWAIT(%)","FLMEMWAIT(%)","FLCACHEWAIT(%)"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }

    puts
    puts "#### Commit Information ####"
    keys= ["Measured Range","0ENDOP(%)","1ENDOP(%)","2/3ENDOP(%)","GPRWAIT(%)","4ENDOP(%)"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }

    puts
    puts "#### Other Information ####"
    keys= ["Measured Range","IPC"]
    putsheader(keys)
    @data_hash[current_process].each_key{|range|
      h = @data_hash[current_process][range]
      putsvalues(keys,h)
    }
  end

  def calcall
    if @max_process == 0
      calcprocess("default")
        if @max_thread >0
          for j in 0..@max_thread
            calcprocess("process0" + " thread" + j.to_s)
          end
        end
 
      else
      for i in 0..@max_process
        calcprocess("process"+i.to_s)
        if @max_thread >0
          for j in 0..@max_thread
            calcprocess("process"+i.to_s + " thread" + j.to_s)
          end
        end
      end
    end
  end

  def showall
    calcall

    putline 
    puts "Type of Program    : " + @type
    puts "CPU frequency #{($FREQ*1e-6).to_i} (MHz)"
    puts "Number of Processes: #{@max_process + 1}"
    puts "Number of Threads: #{@max_thread + 1}" if @max_thread > 0
    putline 
    for i in 0..@max_process
      if @max_process==0
        showprocess("default")
      else
        showprocess("process"+i.to_s)
      end
      if @max_thread >0
        for j in 0..@max_thread
         showprocess("process"+i.to_s + " thread" + j.to_s)
        end
       end
    end

    putline
    puts "Measured Events"
    putline
    len = 0
    @measured_events.each_key{|key|
      if len + key.length > 71
        print "\n"
        len = 0
      end
      print key + " "
      len = len + key.length + 1
    }
    puts
  end

  def putline
    puts "------------------------------------------------------------------------"
  end

end

pa = ProfAnalyser.new

ARGV.each{|file|
  pa.read_file(file)
}

pa.showall
