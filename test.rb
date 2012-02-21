$LOAD_PATH << "."
require 'test/unit'
require 'qw.rb'

class QWTest < Test::Unit::TestCase
  
  def setup
    # fixtures!
    @server_response = "\xFF\xFF\xFF\xFFn\\pm_ktjump\\1\\*version\\MVDSV 0.28 cXE\\*z_ext\\235\\hostname\\tastyspleen.net::MegaTF Co-Op\\maxclients\\26\\maxspectators\\4\\btf_stuff\\1\\*gamedir\\fortress\\footsteps\\on\\airscout\\on\\exec_class\\on\\a\\120\\sg\\on\\allowvote\\1\\autoteam\\off\\teamplay\\21?TeamFortress\\prematch\\0\\teamfrags\\off\\ec\\on\\fpd\\846\\admin\\XavioR\\fraglimit\\200\\timelimit\\0\\deathmatch\\0\\maxfps\\120\\watervis\\1\\n\\0\\*progs\\37006\\*csprogs\\0xef4e612\\map\\rock2a_coop\\MegaTF\\v02.04.12United\\uptime\\d:0 h:5 m:44\n68 247 74 54 \"TempesT\" \"tf_sold\" 13 13\n69 325 41 77 \"\x8D\x1C\xF4\xE8\xE5\x1C\xCE\xE5\xD7\xE2\x91\" \"tattoo\" 13 13\n28 777 92 75 \"\x90\x8F\xD3H\xC1R\xCB\x8F\x91\x90\xCEH\x91\" \"lavaman3\" 13 13\n\x00"
    @master_response = "\xFF\xFF\xFF\xFFd\n\xBC(\x82\nkm\xBC(\x82\nkl\xBC(\x82\nkn\xB2\xD9\xB9hkl\xB2\xD9\xB9hkm\xB21\x064kl\xC2mEKkn\xC2mELkl\xC2mEKkm\xC2mEKklF*J\x03m`>\x18@\v\xAD\x9C\xD9\x1E\xB8hkl>\x8D*HoV>\x8D*HoU\xB2\xD9\xB9hk\xD0?\xFB\x14\xFBu0Wj\xB07knWj\xB07km_\x8F\xF3\x18l4>\x18@\vkm?\xFB\x14\xFBkn?\xFB\x14\xFBkm?\xFB\x14\xFBkl_\x8F\xF3\x18kl>\x18@\vkl[yE\xC9kn[yE\xC9km[yE\xC9kl^}\xFB\x10kn\xC2\xBB+\xF3l4^}\xFB\x10ko^}\xFB\x10km_\x8F\xF3\x18k\xD0[yE\xC9k\xD0^}\xFB\x10kp\xC7\xA7\xC5\x87\x80\xE8J[p\xB1kl\xC2\xBB+\xF3k\xD0Yh\xC2\x92klYh\xC2\x92km\xD4*&Xkm\xD4*&Xkl\xD4*&Xko\xD4*&Xkn\xD4*&XkpT\xEA\xB9\xD7ks\xC2mELoXT\xEA\xB9\xD7ktT\xEA\xB9\xD7kqT\xEA\xB9\xD7kr\xC2mELoU\xC2mELoV\xC2mELoWT\xEA\xB9\xD7klT\xEA\xB9\xD7koT\xEA\xB9\xD7kpT\xEA\xB9\xD7knT\xEA\xB9\xD7k\x7F\xC2\xBB+\xF3kl\xD4m\x80\x94kl\xD4m\x80\x94km\x82U8\x83kl>\x8D*Hkl]Q\xFE?km]Q\xFE?kn]Q\xFE?ko]Q\xFE?klY\x95\xFE,klJ`S klWj\xB07k\xD0CQ;)kl\xBC(gQk\xD0J[p\xB1u0MJ\xC2\xBDkoMJ\xC2\xBDkpMJ\xC2\xBDkmMJ\xC2\xBDknm_\xDF[\xFA\xAE\xC2A\x0Eskm\xD8V\x91\xA5m`\xD0Rg?m`\xD0Rg?mb\xD0Rg?maYh\xC2\x92l\x12_T\xA4\xF5kmYh\xC2\x92kvYh\xC2\x92ktYh\xC2\x92kuYh\xC2\x92krYh\xC2\x92ksYh\xC2\x92kpYh\xC2\x92kqYh\xC2\x92knYh\xC2\x92ko"
  @player_raw = "68 247 74 54 \"TempesT\" \"tf_sold\" 13 14" 
  @expected_rules = {
        "pm_ktjump" => "1",
         "*version" => "MVDSV 0.28 cXE",
           "*z_ext" => "235",
         "hostname" => "tastyspleen.net::MegaTF Co-Op",
       "maxclients" => "26",
    "maxspectators" => "4",
        "btf_stuff" => "1",
         "*gamedir" => "fortress",
        "footsteps" => "on",
         "airscout" => "on",
       "exec_class" => "on",
                "a" => "120",
               "sg" => "on",
        "allowvote" => "1",
         "autoteam" => "off",
         "teamplay" => "21?TeamFortress",
         "prematch" => "0",
        "teamfrags" => "off",
               "ec" => "on",
              "fpd" => "846",
            "admin" => "XavioR",
        "fraglimit" => "200",
        "timelimit" => "0",
       "deathmatch" => "0",
           "maxfps" => "120",
         "watervis" => "1",
                "n" => "0",
           "*progs" => "37006",
         "*csprogs" => "0xef4e612",
              "map" => "rock2a_coop",
           "MegaTF" => "v02.04.12United",
           "uptime" => "d:0 h:5 m:44"
  }

  @expected_players = [ {
           :id => "68",
        :frags => "247",
         :time => "74",
         :ping => "54",
         :name => "TempesT",
         :skin => "tf_sold",
        :shirt => "13",
        :pants => "13"
    },
    {
           :id => "69",
        :frags => "325",
         :time => "41",
         :ping => "77",
         :name => "theNeWb]",
         :skin => "tattoo",
        :shirt => "13",
        :pants => "13"
    },
    {
           :id => "28",
        :frags => "777",
         :time => "92",
         :ping => "75",
         :name => "[SHARK][NH]",
         :skin => "lavaman3",
        :shirt => "13",
        :pants => "13"
    } ]
  end

  def test_can_query_master

  end

  def test_cant_query_non_existant_master

  end

  def test_cant_query_non_existant_server
    s = QW::Server.new( "127.0.0.123", 13371 )
    assert_equal( false, s.query )
  end

  def test_can_parse_master_response
    #QW::Master.from_packet
  end

  def test_can_parse_players_properly
    s = QW::Server.from_packet @server_response
    assert_equal( @expected_players, s.players )    
  end

  def test_can_parse_rules_properly
    s = QW::Server.from_packet @server_response
    assert_equal( @expected_rules, s.rules )  
  end
  
  def test_player_regex
"i68 247 74 54 \"TempesT\" \"tf_sold\" 13 13\n"
    match = QW::Util.player_regex.match( @player_raw )
    assert_not_nil( match )
    assert_equal( "68", match[:id] )
    assert_equal( "247", match[:frags] )
    assert_equal( "54", match[:ping] )
    assert_equal( "74", match[:time] )
    assert_equal( "tf_sold", match[:skin] )
    assert_equal( "13", match[:shirt] )
    assert_equal( "14", match[:pants] )
  end
 
end
