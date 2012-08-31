require 'spec_helper'

describe SGF::Branch do

  let(:root_node) {
    SGF::Node.new({FF: '4', PB: 'Taoism', PW: 'Buddhism'})
  }
  let(:depth1) {
    SGF::Node.new({B: 'QQ'})
  }
  let(:branch) { SGF::Branch.new root_node, depth1 }

  subject { branch }

  its(:size) { should be 2}

end