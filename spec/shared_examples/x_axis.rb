require_relative 'axis_options'

RSpec.shared_examples 'x axis' do
  context 'x axis' do
    include_examples 'axis options', 'x'

    context ':rotate_x_labels' do
      let(:selector) { 'text.xAxisLabels' }

      context 'true' do
        let(:options) { super().merge rotate_x_labels: true }

        it 'rotates the axis labels by 90°' do
          svg.all(selector) {|label| expect(label['transform']).to match /rotate\(\s*90\b/ }
        end
      end

      context 'otherwise' do
        it 'does not rotate the axis labels' do
          svg.all(selector) {|label| expect(label['transform'].to_s).not_to include 'rotate' }
        end
      end
    end
  end

end
