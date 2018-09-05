RSpec.describe Endicia do
  subject { }
  it "has a version number" do
    expect(Endicia::VERSION).not_to be nil
  end

  it "has an config" do 
    # expect( Endicia.new(RSpec.configure) ).not_to be nil
    puts RSpec.configure
    puts "****"
  end

  it "does something useful" do
    expect(false).to eq(false)
  end
end
