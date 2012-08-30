module SGF

#  http://www.red-bean.com/sgf/proplist.html

  class Gametree

    PROPERTIES = {annotator: "AN",
                  black_octisquares: "BO", #Octi
                  black_rank: "BR",
                  black_team: "BT",
                  copyright: "CP",
                  date: "DT",
                  event: "EV",
                  game_content: "GC",
                  handicap: "HA", #Go
                  initial_position: "IP", #Lines of Action
                  invert_y_axis: "IY", #Lines of Action
                  komi: "KM", #Go
                  match_information: "MI", #Backgammon
                  name: "GN",
                  prongs: "NP", #Octi
                  reserve: "NR", #Octi
                  superprongs: "NS", #Octi
                  opening: "ON",
                  overtime: "OT",
                  black_player: "PB",
                  place: "PC",
                  puzzle: "PZ",
                  white_player: "PW",
                  result: "RE",
                  round: "RO",
                  rules: "RU",
                  setup_type: "SU", #Lines of Action
                  source: "SO",
                  time: "TM",
                  data_entry: "US",
                  white_octisquares: "WO", #Octi
                  white_rank: "WR",
                  white_team: "WT"}
  end

  class Node
    PROPERTIES = {
        black_move: "B",
        black_time_left: "BL",
        bad_move: "BM",
        doubtful: "DO",
        interesting: "IT",
        ko: "KO",
        set_move_number: "MN",
        otstones_black: "OB",
        otstones_white: "OW",
        tesuji: "TE",
        white_move: "W",
        white_time_left: "WL",
        add_black: "AB",
        add_empty: "AE",
        add_white: "AW",
        player: "PL",
        arrow: "AR",
        comment: "C",
        circle: "CR",
        dim_points: "DD",
        even_position: "DM", #Yep. No idea how that makes sense.
        figure: "FG",
        good_for_black: "GB",
        good_for_white: "GW",
        hotspot: "HO",
        label: "LB",
        line: "LN",
        mark: "MA",
        node_name: "N",
        print_move_node: "PM", #Am I going to have to code this?
        selected: "SL",
        square: "SQ",
        triangle: "TR",
        unclear_position: "UC",
        value: "V",
        view: "VW",
        application: "AP",
        charset: "CA",
        file_format: "FF",
        game: "GM",
        style: "ST",
        size: "SZ"
    }
  end

end

