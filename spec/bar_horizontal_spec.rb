require 'spec_helper'

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative 'shared_examples/burn_svg_only'

describe SVG::Graph::BarHorizontal do
  context '#burn_svg_only' do
    let(:x_axis) { ['1-10', '10-30', '30-50', '50-70', 'older'] }

    let(:options) do
      {
        width: 640,
        height: 500,
        stack: :side,  # the stack option is valid for Bar graphs only
        fields: x_axis,
        graph_title: "kg per head and year chocolate consumption",
        show_graph_title: true,
        show_x_title: true,
        x_title: 'kg/year',
        rotate_x_labels: false,
        #scale_divisions: 1,
        scale_integers: true,
        x_title_location: :end,
        show_y_title: true,
        rotate_y_labels: false,
        y_title: 'Age in years',
        y_title_location: :end,
        add_popups: true,
        no_css: true,
        bar_gap: true,
        show_percent: true,
        show_actual_values: true
      }
    end

    let(:data1) { [2, 4, 6.777, 4, 2.8] }
    let(:data2) { [1, 5, 4, 5, 2.7] }

    let(:graph) do
      SVG::Graph::BarHorizontal.new(options).tap do |graph|
        graph.add_data( {
          data: data1,
          title: "Dataset1"
        })
        graph.add_data( {
          data: data2,
          title: "Dataset2"
        })
      end
    end

    include_examples 'burn_svg_only'

    it 'can write a coherent SVG file' do
      # graph.burn            # this returns a full valid xml document containing the graph
      # graph.burn_svg_only   # this only returns the <svg>...</svg> node
      expect { File.open(File.expand_path('bar_horizontal.svg',__dir__), 'w') {|f| f.write(graph.burn_svg_only)} }.not_to raise_error
    end
  end
end
