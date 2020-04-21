require 'spec_helper'

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative 'shared_examples/burn_svg_only'

describe SVG::Graph::BarHorizontal do
  context '#burn_svg_only' do
    let(:graph_title) { Faker::Lorem.sentence }
    let(:width) { rand 600..1000 }
    let(:height) { rand 400..500 }
    let(:length) { rand 5..8 }
    let(:x_title) { Faker::Lorem.sentence }
    let(:y_axis) { Faker::Lorem.words length }
    let(:y_title) { Faker::Lorem.sentence }

    let(:options) do
      {
        width: width,
        height: height,
        stack: :side,  # the stack option is valid for Bar graphs only
        fields: y_axis,
        graph_title: graph_title,
        show_graph_title: true,
        show_x_title: true,
        x_title: x_title,
        rotate_x_labels: false,
        #scale_divisions: 1,
        scale_integers: true,
        x_title_location: :end,
        show_y_title: true,
        rotate_y_labels: false,
        y_title: y_title,
        y_title_location: :end,
        add_popups: true,
        no_css: true,
        bar_gap: true,
        show_percent: true,
        show_actual_values: true
      }
    end

    let(:series_count) { rand 2..4 }
    let(:series) do
      Array.new(series_count) do
        {data: Array.new(length) { rand(0.0..10.0).send [:to_f, :to_i].sample }, title: Faker::Lorem.word}
      end
    end

    let(:graph) do
      SVG::Graph::BarHorizontal.new(options).tap do |graph|
        series.each {|series| graph.add_data series }
      end
    end

    include_examples 'burn_svg_only'

    let(:svg) { Capybara.string graph.burn_svg_only }

    it 'can write a coherent SVG file' do
      # graph.burn            # this returns a full valid xml document containing the graph
      # graph.burn_svg_only   # this only returns the <svg>...</svg> node
      expect { File.open(File.expand_path('bar_horizontal.svg',__dir__), 'w') {|f| f.write(graph.burn_svg_only)} }.not_to raise_error
    end

    context 'dimensions' do
      it 'draws the graph to the specified dimensions' do
        root = svg.first 'svg'
        expect(root[:width].to_i).to be == width
        expect(root[:height].to_i).to be == height
      end
    end

    context 'title' do
      it 'draws the graph title' do
        expect(svg).to have_selector 'text', text: graph_title
      end
    end

    context 'legend' do
      it 'draws a legend entry for each series' do
        series.each.with_index(1) do |series, index|
          expect(svg).to have_css "rect.key#{index} + text.keyText", text: series[:title]
        end
      end
    end

    context 'x axis' do
      it 'draws the axis title' do
        expect(svg).to have_selector 'text.xAxisTitle', text: x_title
      end

      it 'draws axis labels' do
        expect(svg).to have_selector 'text.xAxisLabels'
      end
    end

    context 'y axis' do
      it 'draws the axis title' do
        expect(svg).to have_selector 'text.yAxisTitle', text: y_title
      end

      it 'draws the given field names on the y axis' do
        svg.all('text.yAxisLabels').each.with_index do |label, index|
          expect(label.text).to be == y_axis[index]
        end
      end
    end

    context 'guidelines' do
      it 'draws guidelines' do
        expect(svg).to have_selector 'path.guideLines'
      end
    end

    context 'data bars' do
      it 'draws proportional bars for each series' do
        epsilon = 1e-14
        series.each.with_index(1) do |series, index|
          bars = svg.all "rect.fill#{index}"
          scale_factor = bars.first[:width].to_f / series[:data].first

          bars.each.with_index do |bar, index|
            expect(bar[:width].to_f).to be_within(epsilon).of(series[:data][index] * scale_factor)
          end
        end
      end

      it 'labels each bar with value (to 2 decimal places) and rounded percentage' do
        series.each do |series|
          data = series[:data]
          total = data.inject(:+).to_f
          data.each do |value|
            ['text.dataPointLabel', 'text.dataPointLabelBackground'].each do |selector|
              expect(svg).to have_selector selector, text: "#{"%.2f" % value} (#{"%d%%" % (100 * value / total).round})"
            end
          end
        end
      end
    end
  end
end
