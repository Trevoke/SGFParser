# A parser for SGF Files. Main usage: SGF::Tree.new :filename => file_name
module SgfParser

#  http://www.red-bean.com/sgf/proplist.html

# Here we define SGF::Properties, so we can figure out what each property
# is and does.

  property_string = %Q{AB   Add Black       setup            list of stone
AE   Add Empty       setup            list of point
AN   Annotation      game-info        simpletext
AP  Application     root	      composed simpletext ':' simpletext
AR  Arrow           -                list of composed point ':' point
AS  Who adds stones - (LOA)          simpletext
AW   Add White       setup            list of stone
B    Black           move             move
BL   Black time left move             real
BM   Bad move        move             double
BR   Black rank      game-info        simpletext
BT   Black team      game-info        simpletext
C    Comment         -                text
CA  Charset         root	      simpletext
CP   Copyright       game-info        simpletext
CR   Circle          -                list of point
DD  Dim points      - (inherit)      elist of point
DM   Even position   -                double
DO   Doubtful        move             none
DT  Date            game-info        simpletext
EV   Event           game-info        simpletext
FF   Fileformat      root	      number (range: 1-4)
FG  Figure          -                none | composed number ":" simpletext
GB   Good for Black  -                double
GC   Game comment    game-info        text
GM   Game            root	      number (range: 1-5,7-16)
GN   Game name       game-info        simpletext
GW   Good for White  -                double
HA   Handicap        game-info (Go)   number
HO   Hotspot         -                double
IP  Initial pos.    game-info (LOA)  simpletext
IT   Interesting     move             none
IY  Invert Y-axis   game-info (LOA)  simpletext
KM   Komi            game-info (Go)   real
KO   Ko              move             none
LB  Label           -                list of composed point ':' simpletext
LN  Line            -                list of composed point ':' point
MA   Mark            -                list of point
MN   set move number move             number
N    Nodename        -                simpletext
OB   OtStones Black  move             number
ON   Opening         game-info        simpletext
OT  Overtime        game-info        simpletext
OW   OtStones White  move             number
PB   Player Black    game-info        simpletext
PC   Place           game-info        simpletext
PL   Player to play  setup            color
PM  Print move mode - (inherit)      number
PW   Player White    game-info        simpletext
RE  Result          game-info        simpletext
RO   Round           game-info        simpletext
RU  Rules           game-info        simpletext
SE  Markup          - (LOA)          point
SL   Selected        -                list of point
SO   Source          game-info        simpletext
SQ  Square          -                list of point
ST  Style           root	      number (range: 0-3)
SU  Setup type      game-info (LOA)  simpletext
SZ  Size            root	      (number | composed number ':' number)
TB   Territory Black - (Go)           elist of point
TE   Tesuji          move             double
TM   Timelimit       game-info        real
TR   Triangle        -                list of point
TW   Territory White - (Go)           elist of point
UC   Unclear pos     -                double
US   User            game-info        simpletext
V    Value           -                real
VW  View            - (inherit)      elist of point
W    White           move             move
WL   White time left move             real
WR   White rank      game-info        simpletext
WT   White team      game-info        simpletext }

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

  # All this work for this minuscule line!
  PROPERTIES = hash

end

