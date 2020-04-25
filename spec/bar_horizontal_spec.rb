require 'spec_helper'

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative 'shared_contexts/bar_graph'
require_relative 'shared_examples/a_bar_graph'
require_relative 'shared_examples/axis_labels'
require_relative 'shared_examples/axis_options'
require_relative 'shared_examples/x_axis'

describe SVG::Graph::BarHorizontal do
  context '#burn_svg_only' do
    include_context 'bar graph' do
      let(:extra_options) do
        {
          #scale_divisions: 1,
          bar_gap: true
        }
      end
    end

    it_behaves_like 'a bar graph', scale_dimension: :width

    let(:svg) { Capybara.string graph.burn_svg_only }

    it 'can write a coherent SVG file' do
      # graph.burn            # this returns a full valid xml document containing the graph
      # graph.burn_svg_only   # this only returns the <svg>...</svg> node
      expect { File.open(File.expand_path('bar_horizontal.svg',__dir__), 'w') {|f| f.write(graph.burn_svg_only)} }.not_to raise_error
    end

    context 'axes' do
      include_examples 'axis labels', 'y'
      include_examples 'x axis'

      context 'y axis' do # TODO: unify with bar_spec once we figure out how to express the slightly different behavior
        include_examples 'axis options', 'y'

        context ':rotate_y_labels' do
          let(:selector) { 'text.yAxisLabels' }

          context 'false' do
            let(:options) { super().merge rotate_y_labels: false }

            it 'does not rotate the axis labels' do
              svg.all(selector) {|label| expect(label['transform'].to_s).not_to include 'rotate' }
            end
          end

          context 'otherwise' do
            it 'rotates the axis labels by 90°' do
              svg.all(selector) {|label| expect(label['transform']).to match /rotate\(\s*90\b/ }
            end
          end
        end
      end
    end
  end
end
