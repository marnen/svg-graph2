require_relative '../lib/svggraph'

describe SVG::Graph::Graph do
  let(:dummy_graph) do
    Class.new(described_class) do
      def get_css; end
      def draw_data; end

      def get_x_labels
        []
      end
      def get_y_labels
        []
      end
    end
  end

  describe '#to_iruby' do
    let(:graph) { dummy_graph.new({}).tap {|graph| graph.add_data data: [1, 2, 3] } }

    it 'returns an HTML MIME type identifier and the SVG content of the graph' do
      expect(graph.to_iruby).to be == ['text/html', graph.burn_svg_only]
    end
  end
end
