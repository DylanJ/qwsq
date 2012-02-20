require 'bit-struct'
require 'socket'
require 'awesome_print'

# QW Stuff
# fish

# quake text was a custom charset that mapped to a bitmap
# so that each character was a byte which represented an
# index on that map. - magic johnston.
def quake_text str 
  str.bytes.to_a.collect{ |c| @quake_charset[c] }.reject{ |c| c == 0xFF.chr }.join
end 

module QW 
  
  class Util
    def self.send_cmd( ip, port, proto )
      cmd_to_send = "#{proto}\n\0"

      sock = UDPSocket.new
      sock.connect( ip, port )
      sock.send cmd_to_send, 0
      sock.recvfrom(204800) # i saw a number around this size once.
    end
  end
  
  class ServerAddress < BitStruct
    unsigned :ip_0,   8,  "First Octet"
    unsigned :ip_1,   8,  "Second Octet"
    unsigned :ip_2,   8,  "Third Octet"
    unsigned :ip_3,   8,  "Fourth Octet"
    unsigned :port,  32,  "Port", :endian => :big
  end

  class Server
    attr_reader :rules
      
    

  end

  class Master
    attr_reader :hostname, :map
  end

end

ap x = QW::Server.new 
ap QW::Server.get_poop

__END__

# <3

QWM_SERVERLIST = 'c'
QWS_SERVERINFO = "\xFF\xFF\xFF\xFFstatus" 
@player_regex = /(?<id>\d+) (?<frags>-?\d+) (?<time>\d+) (?<ping>\d+) \"(?<name>.*)\" \"(?<skin>.*)\" (?<shirt>\d+) (?<pants>\d+)/
@quake_charset = "\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF[]0123456789\xFF\xFF\xFF\xFF !\"\#$%&'()*+,-./0123456789:;(=)?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~<\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF\xFF[]0123456789\xFF\xFF\xFF\xFF !\"\#$%&'()*+,-./0123456789:;(=)?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_'abcdefghijklmnopqrstuvwxyz{|}~<"


def get_server_info( ip, port )
  data = send_cmd( ip, port, QWS_SERVERINFO )[0]
  data = data.byteslice( 6 .. data.length - 3 ).split("\n") # datadatadata\nplayer\nplayer\nplayer\n
  server_rules = data[0].split("\\") # key values seperated by \ 
  
  server_info = Hash[*server_rules]
  data.shift
  players = data.collect do |player|
    p = @player_regex.match(player) 
    Hash[*p.names.map{|k|v=k!='name'?p[k.to_sym]:quake_text(p[:name]);[k.to_sym,v]}.flatten]
  end

  { :rules => server_info, :players => players }
end

def get_servers_from_master( ip, port )
  data = send_cmd( ip, port, QWM_SERVERLIST )

  num_addr_returned = data[0].length / 6
  servers = []
  
  # bust these guys into 6 bytes each
  data[0].unpack("a6"*num_addr_returned).to_a.collect do |address|
    sa = ServerAddress.new address
    addr = "#{sa.ip_0}.#{sa.ip_1}.#{sa.ip_2}.#{sa.ip_3}"
    port = sa.port >> 16 
    { :ip => addr, :port => port }
  end
end

#ap get_server_info( "74.86.171.201", 27500 )
#ap get_server_info( "74.86.171.201", 27500 )
servers = []
get_servers_from_master( "188.40.112.251", 27000 ).each do |server|
  if ( server[:ip] == "255.255.255.255" )
    next
  end
  servers << get_server_info( server[:ip], server[:port] )
end

ap servers

