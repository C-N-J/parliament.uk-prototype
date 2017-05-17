require 'rails_helper'

RSpec.describe 'parliaments', type: :routing do
  describe 'ParliamentsController' do
    include_examples 'index route', 'parliaments'
  end
end
