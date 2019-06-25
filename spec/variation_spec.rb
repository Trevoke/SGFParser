# typed: false
# frozen_string_literal: true

require 'spec_helper'

module SGF
  RSpec.describe Variation do
    subject { Variation.new }
    it 'begins with a Node' do
      expect(subject.root).to be_an_instance_of Node
    end

    it 'accepts more nodes' do
      subject.append Node.new
      expect(subject.size).to eq 2
    end
  end
end
