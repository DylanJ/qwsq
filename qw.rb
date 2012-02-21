require 'bit-struct'
require 'socket'
require 'awesome_print'

# QW Stuff
# fish

class String
  # quake text uses a custom charset that maps to a bitmap
  # so that each character is a byte which represents an
  # index on that map. - magic johnston.
  def q_to_s
    text = self.dup
    text.bytes.to_a.collect{ |c| @@quake_charset[c] }.reject{ |c| c == 0xFF.chr }.join
  end
  
  private
  @@quake_charset = "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF[]0123456789\xFF\xFF\xFF\xFF !\"\#$%&'()*+,-./0123456789:;(=)?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~<\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF[]0123456789\xFF\xFF\xFF\xFF !\"\#$%&'()*+,-./0123456789:;(=)?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~<"
end

module QW 
  QWM_SERVERLIST = 'c'
  QWS_SERVERINFO = "\xFF\xFF\xFF\xFFstatus" 
  
  class Util
    def self.player_regex
      /(?<id>\d+) (?<frags>-?\d+) (?<time>\d+) (?<ping>\d+) \"(?<name>.*)\" \"(?<skin>.*)\" (?<shirt>\d+) (?<pants>\d+)/
    end
   
    # send and recv a cmd (blocks)
    def self.send_cmd( ip, port, proto )
      cmd_to_send = "#{proto}\n\0"

      sock = UDPSocket.new
      sock.connect( ip, port )
      
      begin
        sock.send cmd_to_send, 0
        data = sock.recvfrom(204800)[0] # i saw a number around this size once.%
      rescue Errno::ECONNREFUSED
        data = nil    
      end
      data
    end
  end

  class Server 
    attr_reader :rules, :players
    attr_accessor :ip, :port

    def initialize( ip="", port=27500 )
      @ip = ip
      @port = port
    end

    def self.from_address( ip, port )
      Server.new( ip, port )
    end
    
    def self.from_packet( packet )
      s = Server.new
      s.parse_response packet
      s
    end
    
    # ask server for info. 
    def query
      return false if ( @ip.empty? )
      
      data = Util.send_cmd( @ip, @port, QWS_SERVERINFO )
      return false if data.nil?
      
      parse_response data
    end

    def parse_response data
      # datadatadata\nplayer\nplayer\nplayer\n
      data = data.byteslice( 6 .. data.length - 3 ).split("\n") 
      rules_array = data[0].split("\\") # key values seperated by \ 
      
      @rules = Hash[*rules_array] # trick to turn a,b,c,d into a=>b,c=>
      
      data.shift # first element contains rules
      @players = data.collect do |player|
        p = Util.player_regex.match(player) 
        Hash[*p.names.map{|k|v=k!='name'?p[k.to_sym]:p[:name].q_to_s;[k.to_sym,v]}.flatten] # haha
      end
      
      true
    end
  end

  class Master
    attr_accessor :ip, :port
    attr_reader :servers
    class ServerAddress < BitStruct
      unsigned :ip_0,   8,  "First Octet"
      unsigned :ip_1,   8,  "Second Octet"
      unsigned :ip_2,   8,  "Third Octet"
      unsigned :ip_3,   8,  "Fourth Octet"
      unsigned :port,  32,  "Port", :endian => :big
    end
   
    def initialize( ip="", port=27500 )
      @ip = ip
      @port = port
    end

    def self.from_address( ip, port )
      Master.new( ip, port )
    end
    
    def self.from_packet( packet )
      s = Master.new
      s.parse_response packet
      s
    end
    
    def query
      return false if ( @ip.empty? )
     
      data = Util.send_cmd( @ip, @port, QWM_SERVERLIST )
      return false if data.nil?
      
      parse_response data
    end
    
    def parse_response data
      num_returned = (data.length / 6)-1 # each addr is 6 bytes
      
      # bust these guys into 6 bytes each
      @servers = data.unpack("xxxxxx"+ "a6"*num_returned).to_a.collect do |address|
        sa = ServerAddress.new address
        addr = "#{sa.ip_0}.#{sa.ip_1}.#{sa.ip_2}.#{sa.ip_3}"
        port = sa.port >> 16 
        
        { :ip => addr, :port => port }
      end
    
      true
    end
  end
end

