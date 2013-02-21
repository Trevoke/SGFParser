require 'spec_helper'

module SGF
  describe Variation do
    subject { Variation.new }
    its(:root) { should be_an_instance_of Node }
    it "accepts more nodes" do
      subject.append Node.new
      subject.size.should eq 2
    end
  end
end
