module SGF

#  http://www.red-bean.com/sgf/proplist.html

# Here we define SGF::Properties, so we can figure out what each property
# is and does.

  property_string = %Q{AB   Add Black       setup            list of stone
AE   Add Empty       setup            list of point
AP  Application     root	      composed simpletext ':' simpletext
AR  Arrow           -                list of composed point ':' point
AS  Who adds stones - (LOA)          simpletext
AW   Add White       setup            list of stone
B    Black           move             move
BL   Black time left move             real
BM   Bad move        move             double
C    Comment         -                text
CA  Charset         root	      simpletext
CR   Circle          -                list of point
DD  Dim points      - (inherit)      elist of point
DM   Even position   -                double
DO   Doubtful        move             none
FF   Fileformat      root	      number (range: 1-4)
FG  Figure          -                none | composed number ":" simpletext
GB   Good for Black  -                double
GM   Game            root	      number (range: 1-5,7-16)
GW   Good for White  -                double
HO   Hotspot         -                double
IT   Interesting     move             none
KO   Ko              move             none
LB  Label           -                list of composed point ':' simpletext
LN  Line            -                list of composed point ':' point
MA   Mark            -                list of point
MN   set move number move             number
N    Nodename        -                simpletext
OB   OtStones Black  move             number
OW   OtStones White  move             number
PL   Player to play  setup            color
PM  Print move mode - (inherit)      number
SE  Markup          - (LOA)          point
SL   Selected        -                list of point
SQ  Square          -                list of point
ST  Style           root	      number (range: 0-3)
SZ  Size            root	      (number | composed number ':' number)
TB   Territory Black - (Go)           elist of point
TE   Tesuji          move             double
TR   Triangle        -                list of point
TW   Territory White - (Go)           elist of point
UC   Unclear pos     -                double
V    Value           -                real
VW  View            - (inherit)      elist of point
W    White           move             move
WL   White time left move             real}

  property_array = property_string.split("\n")
  hash = {}
  property_array.each do |set|
    temp = set.gsub("\t", "        ")
    id = temp[0..3].strip
    desc = temp[4..19].strip
    property_type = temp[20..35].strip
    property_value = temp[37..-1].strip
    hash[id] = [desc, property_type, property_value]
  end

  #This holds a hash of all the official properties for FF4
  PROPERTIES = hash

  class Game

    PROPERTIES = {"annotator"=>"AN",
                  "black_octisquares"=>"BO", #Octi
                  "black_rank"=>"BR",
                  "black_team"=>"BT",
                  "copyright"=>"CP",
                  "date"=>"DT",
                  "event"=>"EV",
                  "game_content"=>"GC",
                  "handicap"=>"HA", #Go
                  "initial_position"=>"IP", #Lines of Action
                  "invert_y_axis"=>"IY", #Lines of Action
                  "komi"=>"KM", #Go
                  "match_information"=>"MI", #Backgammon
                  "name"=>"GN",
                  "prongs"=>"NP", #Octi
                  "reserve"=>"NR", #Octi
                  "superprongs"=>"NS", #Octi
                  "opening"=>"ON",
                  "overtime"=>"OT",
                  "black_player"=>"PB",
                  "place"=>"PC",
                  "puzzle"=>"PZ",
                  "white_player"=>"PW",
                  "result"=>"RE",
                  "round"=>"RO",
                  "rules"=>"RU",
                  "setup_type"=>"SU", #Lines of Action
                  "source"=>"SO",
                  "time"=>"TM",
                  "data_entry"=>"US",
                  "white_octisquares"=>"WO", #Octi
                  "white_rank"=>"WR",
                  "white_team"=>"WT"}
  end
end

