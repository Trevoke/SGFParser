$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'lib'))
require 'sgf'
require 'fileutils'
require 'rspec'
require 'rspec/autorun'

ONE_LINE_SIMPLE_SAMPLE_SGF= "(;FF[4]AP[Primiview:3.1]GM[1]SZ[19](;DD[kq:os][dq:hs]AR[aa:sc][sa:ac][aa:sa][aa:ac][cd:cj][gd:md][fh:ij][kj:nh]LN[pj:pd][nf:ff][ih:fj][kh:nj]C[Arrows, lines and dimmed points.])(;B[qd]N[Style & text type]))(;FF[4]AP[Primiview:3.1]GM[1]SZ[19])"

SIMPLIFIED_SAMPLE_SGF= <<EOF
(;FF[4]AP[Primiview:3.1]GM[1]SZ[19]
  (;DD[kq:os][dq:hs]
    AR[aa:sc][sa:ac][aa:sa][aa:ac][cd:cj]
    [gd:md][fh:ij][kj:nh]
    LN[pj:pd][nf:ff][ih:fj][kh:nj]
    C[Arrows, lines and dimmed points.])
  (;B[qd]N[Style & text type])
)
(;FF[4]AP[Primiview:3.1]GM[1]SZ[19])
EOF

def get_first_game_from file
  collection = get_collection_from file
  collection.gametrees.first
end

def get_collection_from file
  parser = SGF::Parser.new
  parser.parse File.read(file)
end