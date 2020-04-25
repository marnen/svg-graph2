require 'spec_helper'

require_relative '../lib/SVG/Graph/Bar'
require_relative 'shared_contexts/bar_graph'
require_relative 'shared_examples/a_bar_graph'

describe SVG::Graph::Bar do
  context '#burn_svg_only' do
    include_context 'bar graph' do
      let(:extra_options) do
        {
          stagger_x_labels: true,
          # x_axis_position: 0,
          # y_axis_position: '30-50',
        }
      end
    end

    it_behaves_like 'a bar graph', label_axis: 'x', scale_dimension: :height, rotate_y_labels_default: false

    let(:svg) { Capybara.string graph.burn_svg_only }

    it 'can write a coherent SVG file' do
      # graph.burn            # this returns a full valid xml document containing the graph
      # graph.burn_svg_only   # this only returns the <svg>...</svg> node
      expect { File.open(File.expand_path('bar.svg',__dir__), 'w') {|f| f.write(graph.burn_svg_only)} }.not_to raise_error
    end
  end
end
