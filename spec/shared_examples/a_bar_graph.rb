require_relative './burn_svg_only'

RSpec.shared_examples 'a bar graph' do |scale_dimension:|
  include_examples 'burn_svg_only'

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
