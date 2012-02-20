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

      sock_master = UDPSocket.new
      sock_master.connect( ip, port )
      sock_master.send cmd_to_send, 0
      sock_master.recvfrom(204800) # i saw a number around this size once.
    end
  end

  class Server 
    attr_reader :rules, :players
    
    def initialize( ip, port )
      data = Util.send_cmd( ip, port, QWS_SERVERINFO )[0]
      data = data.byteslice( 6 .. data.length - 3 ).split("\n") # datadatadata\nplayer\nplayer\nplayer\n
      rules_array = data[0].split("\\") # key values seperated by \ 
      
      @rules = Hash[*rules_array] # trick to turn a,b,c,d into a=>b,c=>d
      data.shift # first item is retarded
      
      @players = data.collect do |player|
        p = Util.player_regex.match(player) 
        Hash[*p.names.map{|k|v=k!='name'?p[k.to_sym]:p[:name].q_to_s;[k.to_sym,v]}.flatten] # haha
      end
    end
  end

  class Master
    class ServerAddress < BitStruct
      unsigned :ip_0,   8,  "First Octet"
      unsigned :ip_1,   8,  "Second Octet"
      unsigned :ip_2,   8,  "Third Octet"
      unsigned :ip_3,   8,  "Fourth Octet"
      unsigned :port,  32,  "Port", :endian => :big
    end
    
    def initialize( ip, port, query = false )
      data = Util.send_cmd( ip, port, QW::QWM_SERVERLIST )

      num_returned = data[0].length / 6
      
      # bust these guys into 6 bytes each
      @servers = data[0].unpack("a6"*num_returned).to_a.collect do |address|
        sa = ServerAddress.new address
        addr = "#{sa.ip_0}.#{sa.ip_1}.#{sa.ip_2}.#{sa.ip_3}"
        port = sa.port >> 16 
        
        if query
          { :ip => addr, :port => port, :server => Server.new( ip, port ) }
        else
          { :ip => addr, :port => port }
        end
      end
    end
  end
end

# <3
x =  QW::Server.new( "74.86.171.201", 27500 )
ap x.rules
ap x.players



#ap get_server_info( "74.86.171.201", 27500 )
#ap get_server_info( "74.86.171.201", 27500 )
#servers = []
#get_servers_from_master( "188.40.112.251", 27000 ).each do |server|
#  if ( server[:ip] == "255.255.255.255" )
#    next
#  end
#  servers << get_server_info( server[:ip], server[:port] )
#end

#ap servers

