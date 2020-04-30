RSpec.shared_examples 'a graph' do |show_graph_title_default:|
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
