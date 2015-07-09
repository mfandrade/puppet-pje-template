require 'spec_helper'
describe 'pje' do

  context 'with defaults for all parameters' do
    it { should contain_class('pje') }
  end
end
