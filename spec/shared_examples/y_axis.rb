RSpec.shared_examples 'y axis' do |rotate_y_labels_default:|
  context 'y axis' do # TODO: unify with bar_horizontal_spec once we figure out how to express the slightly different behavior
    include_examples 'axis options', 'y'

    context ':rotate_y_labels' do
      let(:selector) { 'text.yAxisLabels' }

      shared_examples 'true' do
        it 'rotates the axis labels by 90°' do
          svg.all(selector) {|label| expect(label['transform']).to match /rotate\(\s*90\b/ }
        end
      end

      shared_examples 'false' do
        it 'does not rotate the axis labels' do
          svg.all(selector) {|label| expect(label['transform'].to_s).not_to include 'rotate' }
        end
      end

      context 'true' do
        let(:options) { super().merge rotate_y_labels: true }
        it_behaves_like 'true'
      end

      context 'false' do
        let(:options) { super().merge rotate_y_labels: false }
        it_behaves_like 'false'
      end

      context 'otherwise' do
        it_behaves_like rotate_y_labels_default.to_s
      end
    end
  end

end
