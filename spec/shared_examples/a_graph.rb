RSpec.shared_examples 'a graph' do |key_default:, show_graph_title_default:|
  context 'legend' do
    context ':key' do
      shared_examples 'true' do
        it 'draws a legend entry for each series' do
          series.each.with_index(1) do |series, index|
            expect(svg).to have_css "rect.key#{index} + text.keyText", text: series[:title]
          end
        end
      end

      shared_examples 'false' do
        it 'does not draw a legend' do
          (1..series_count).each {|index| expect(svg).not_to have_selector ".key#{index}" }
          expect(svg).not_to have_selector '.keyText'
        end
      end

      context 'true' do
        let(:options) { super().merge key: true }
        it_behaves_like 'true'
      end

      context 'false' do
        let(:options) { super().merge key: false }
        it_behaves_like 'false'
      end

      context 'default' do
        it_behaves_like key_default.to_s
      end
    end
  end

  context ':show_graph_title' do
    shared_examples 'true' do
      it 'draws the graph title' do
        expect(svg).to have_selector 'text', text: graph_title
      end
    end

    shared_examples 'false' do
      it 'does not draw the graph title' do
        expect(svg).not_to have_selector 'text', text: graph_title
      end
    end

    context 'true' do
      let(:options) { super().merge show_graph_title: true }
      it_behaves_like 'true'
    end

    context 'false' do
      let(:options) { super().merge show_graph_title: false }
      it_behaves_like 'false'
    end

    context 'otherwise' do
      it_behaves_like show_graph_title_default.to_s
    end
  end
end
