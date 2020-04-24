RSpec.shared_examples 'axis labels' do |label_axis|
  context "#{label_axis} axis" do
    it "draws the given field names on the #{label_axis} axis" do
      svg.all("text.#{label_axis}AxisLabels").each.with_index do |label, index|
        expect(label.text).to be == fields[index]
      end
    end
  end
end
