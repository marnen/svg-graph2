require 'spec_helper'

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative 'shared_contexts/bar_graph'
require_relative 'shared_examples/a_bar_graph'
require_relative 'shared_examples/axis_labels'
require_relative 'shared_examples/axis_options'
require_relative 'shared_examples/x_axis'
require_relative 'shared_examples/y_axis'

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
      include_examples 'y axis', rotate_y_labels_default: true
    end
  end
end
