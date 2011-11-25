require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "SGF::Writer" do

  TEMP_FILE = 'spec/data/temp.sgf'

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

  ONE_LINE_SIMPLE_SAMPLE_SGF= "(;FF[4]AP[Primiview:3.1]GM[1]SZ[19](;DD[kq:os][dq:hs]AR[aa:sc][sa:ac][aa:sa][aa:ac][cd:cj][gd:md][fh:ij][kj:nh]LN[pj:pd][nf:ff][ih:fj][kh:nj]C[Arrows, lines and dimmed points.])(;B[qd]N[Style & text type]))(;FF[4]AP[Primiview:3.1]GM[1]SZ[19])"

  after :each do
    FileUtils.rm_f TEMP_FILE
  end

  it "should save a simple tree properly" do
    sgf = File.read('spec/data/simple.sgf')
    parse_save_load_and_compare_to_saved sgf
  end

  it "should save an SGF with two gametrees properly" do
    parse_save_load_and_compare_to_saved "(;FF[4])(;FF[4])"
  end

  it "should save the one-line simplified sample" do
    parse_save_load_and_compare_to_saved ONE_LINE_SIMPLE_SAMPLE_SGF
  end

  it "should save the simplified SGF properly" do
    parse_save_load_and_compare_to_saved SIMPLIFIED_SAMPLE_SGF
  end

  it "should save the sample SGF properly" do
    sgf = File.read('spec/data/ff4_ex.sgf')
    parse_save_load_and_compare_to_saved sgf
  end

  private

  def parse_save_load_and_compare_to_saved string
    parser =SGF::Parser.new
    tree = parser.parse string
    tree.save TEMP_FILE
    tree2 = get_tree_from TEMP_FILE
    tree2.should == tree
  end

end