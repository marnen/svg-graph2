RSpec.shared_examples 'axis options' do |axis|
  context ":show_#{axis}_title" do
    let(:selector) { "text.#{axis}AxisTitle" }

    context 'true' do
      let(:options) { super().merge "show_#{axis}_title": true }

      it 'draws the axis title' do
        expect(svg).to have_selector selector, text: self.send("#{axis}_title")
      end
    end

    context 'otherwise' do
      it 'does not draw the axis title' do
        expect(svg).not_to have_selector selector
      end
    end
  end

  context 'labels' do
    let(:selector) { "text.#{axis}AxisLabels" }

    context ":show_#{axis}_labels" do
      context 'false' do
        let(:options) { super().merge "show_#{axis}_labels": false }

        it 'does not draw axis labels' do
          expect(svg).not_to have_selector selector
        end
      end

      context 'otherwise' do
        it 'draws axis labels' do
          expect(svg).to have_selector selector
        end
      end
    end
  end
end
