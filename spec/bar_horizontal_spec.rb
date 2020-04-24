require 'spec_helper'

require_relative '../lib/SVG/Graph/BarHorizontal'
require_relative 'shared_examples/a_bar_graph'

describe SVG::Graph::BarHorizontal do
  context '#burn_svg_only' do
    let(:graph_title) { Faker::Lorem.sentence }
    let(:width) { rand 600..1000 }
    let(:height) { rand 400..500 }
    let(:length) { rand 5..8 }
    let(:x_title) { Faker::Lorem.sentence }
    let(:y_axis) { Faker::Lorem.words number: length }
    let(:y_title) { Faker::Lorem.sentence }

    let(:options) do
      {
        width: width,
        height: height,
        stack: :side,  # the stack option is valid for Bar graphs only
        fields: y_axis,
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

    it_behaves_like 'a bar graph'

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
      context ':show_graph_title is true' do
        let(:options) { super().merge show_graph_title: true }

        it 'draws the graph title' do
          expect(svg).to have_selector 'text', text: graph_title
        end
      end

      context 'otherwise' do
        it 'does not draw the graph title' do
          expect(svg).not_to have_selector 'text', text: graph_title
        end
      end
    end

    context 'legend' do
      context ':key is false' do
        let(:options) { super().merge key: false }

        it 'does not draw a legend' do
          (1..series_count).each {|index| expect(svg).not_to have_selector ".key#{index}" }
          expect(svg).not_to have_selector '.keyText'
        end
      end


      context 'otherwise' do
        it 'draws a legend entry for each series' do
          series.each.with_index(1) do |series, index|
            expect(svg).to have_css "rect.key#{index} + text.keyText", text: series[:title]
          end
        end
      end
    end

    context 'axes' do
      shared_examples 'axis options' do |axis|
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

      context 'y axis' do
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

        it 'draws the given field names on the y axis' do
          svg.all('text.yAxisLabels').each.with_index do |label, index|
            expect(label.text).to be == y_axis[index]
          end
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
        epsilon = 1e-13
        series.each.with_index(1) do |series, index|
          bars = svg.all "rect.fill#{index}"
          scale_factor = bars.first[:width].to_f / series[:data].first

          bars.each.with_index do |bar, index|
            expect(bar[:width].to_f).to be_within(epsilon).of(series[:data][index] * scale_factor)
          end
        end
      end

      context 'labels and popups' do
        shared_examples ':show_percent and :show_actual_values' do |selector_or_array|
          context do
            let(:selectors) { Array selector_or_array }

            context ':show_percent is true' do
              let(:options) { super().merge show_percent: true }

              context ':show_actual_values is false' do
                let(:options) { super().merge show_actual_values: false }

                it 'displays percentage only for each bar' do
                  each_series_by_value do |value, total|
                    selectors.each do |selector|
                      expect(svg).to have_selector selector, exact_text: percentage(value, total), normalize_ws: true
                    end
                  end
                end
              end

              context 'otherwise' do
                it 'displays value (to 2 decimal places) and rounded percentage for each bar' do
                  each_series_by_value do |value, total|
                    selectors.each do |selector|
                      expect(svg).to have_selector selector, exact_text: "#{formatted_value value} #{percentage value, total}"
                    end
                  end
                end
              end
            end

            context 'otherwise' do
              context ':show_actual_values is false' do
                let(:options) { super().merge show_actual_values: false }

                it 'does not display any text' do
                  selectors.each do |selector|
                    expect(svg).not_to have_selector selector, text: /\S/
                  end
                end
              end

              context 'otherwise' do
                it 'displays values only (to 2 decimal places) for each bar' do
                  each_series_by_value do |value, total|
                    selectors.each do |selector|
                      expect(svg).to have_selector selector, exact_text: formatted_value(value)
                    end
                  end
                end
              end
            end

            private

            def each_series_by_value(&block)
              series.each do |series|
                data = series[:data]
                total = data.sum.to_f
                data.each do |value|
                  block.call value, total
                end
              end
            end

            def formatted_value(value)
              "%.2f" % value
            end

            def percentage(value, total)
              "(%d%%)" % (100 * value / total).round
            end
          end
        end

        context 'labels' do
          include_examples ':show_percent and :show_actual_values', ['text.dataPointLabel', 'text.dataPointLabelBackground']
        end

        context 'popups' do
          context ':add_popups is true' do
            let(:options) { super().merge add_popups: true }

            include_examples ':show_percent and :show_actual_values', 'text.dataPointPopup'
          end

          context 'otherwise' do
            it 'does not draw popups' do
              expect(svg).not_to have_selector 'text.dataPointPopup'
            end
          end
        end
      end
    end
  end
end
