require_relative 'a_graph'
require_relative 'axis_options'
require_relative 'burn_svg_only'

RSpec.shared_examples 'a bar graph' do |label_axis:, scale_dimension:, rotate_y_labels_default:, supports_customized_data_labels: true, normalize_popup_formatting: true|
  include_examples 'burn_svg_only'
  it_behaves_like 'a graph', key_default: true, show_graph_title_default: false

  context 'dimensions' do
    it 'draws the graph to the specified dimensions' do
      root = svg.first 'svg'
      expect(root[:width].to_i).to be == width
      expect(root[:height].to_i).to be == height
    end
  end

  context 'axes' do
    context "#{label_axis} axis" do
      it "draws the given field names on the #{label_axis} axis" do
        svg.all("text.#{label_axis}AxisLabels").each.with_index do |label, index|
          expect(label.text.strip).to be == fields[index]
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

  context 'guidelines' do
    it 'draws guidelines' do
      expect(svg).to have_selector 'path.guideLines'
    end
  end

  context 'data bars' do
    it 'draws proportional bars for each series' do
      epsilon = 1e-12
      series.each.with_index(1) do |series, index|
        bars = svg.all "rect.fill#{index}"
        scale_factor = bars.first[scale_dimension].to_f / series[:data].first

        bars.each.with_index do |bar, index|
          expect(bar[scale_dimension].to_f).to be_within(epsilon).of(series[:data][index] * scale_factor)
        end
      end
    end

    context 'labels and popups' do
      shared_examples ':show_percent and :show_actual_values' do |selector_or_array, normalize_formatting: true|
        context do
          let(:normalize_formatting) { normalize_formatting }
          let(:selectors) { Array selector_or_array }

          if supports_customized_data_labels
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
          end

          context 'otherwise' do
            if supports_customized_data_labels
              context ':show_actual_values is false' do
                let(:options) { super().merge show_actual_values: false }

                it 'does not display any text' do
                  selectors.each do |selector|
                    expect(svg).not_to have_selector selector, text: /\S/
                  end
                end
              end
            end

            context 'otherwise' do
              it 'displays values only (to 2 decimal places) for each bar' do
                each_series_by_value do |value, total|
                  selectors.each do |selector|
                    expect(svg).to have_selector selector, exact_text: formatted_value(value), normalize_ws: true
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
            normalize_formatting ? ('%.2f' % value) : value.to_s
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

          include_examples ':show_percent and :show_actual_values', 'text.dataPointPopup', normalize_formatting: normalize_popup_formatting
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
