require 'spec_helper'

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative 'shared_examples/a_bar_graph'
require_relative 'shared_examples/axis_labels'
require_relative 'shared_examples/axis_options'
require_relative 'shared_examples/x_axis'

describe SVG::Graph::BarHorizontal do
  context '#burn_svg_only' do
    let(:graph_title) { Faker::Lorem.sentence }
    let(:width) { rand 600..1000 }
    let(:height) { rand 400..500 }
    let(:length) { rand 5..8 }
    let(:x_title) { Faker::Lorem.sentence }
    let(:fields) { Faker::Lorem.words number: length }
    let(:y_title) { Faker::Lorem.sentence }

    let(:options) do
      {
        width: width,
        height: height,
        stack: :side,  # the stack option is valid for Bar graphs only
        fields: fields,
        graph_title: graph_title,
        x_title: x_title,
        #scale_divisions: 1,
        scale_integers: true,
        x_title_location: :end,
        y_title: y_title,
        y_title_location: :end,
        no_css: true,
        bar_gap: true
      }
    end

    let(:series_count) { rand 2..4 }
    let(:series) do
      Array.new(series_count) do
        {data: Array.new(length) { rand(1.0..10.0).send [:to_f, :to_i].sample }, title: Faker::Lorem.word}
      end
    end

    let(:graph) do
      SVG::Graph::BarHorizontal.new(options).tap do |graph|
        series.each {|series| graph.add_data series }
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
