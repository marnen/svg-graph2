require_relative '../lib/svggraph'
require_relative '../lib/SVG/Graph/DataPoint'

# TODO: these tests should go in shared examples called from their respective class specs.

describe 'bar, line, and pie' do
  let(:fields) { %w(Jan Feb Mar) }
  let(:data_sales_02) { [12, 45, 21] }

  [SVG::Graph::Bar, SVG::Graph::BarHorizontal, SVG::Graph::Line, SVG::Graph::Pie].each do |klass|
    describe '#burn' do
      it 'writes a graph including credits for SVG::Graph' do
        graph = klass.new(
          :height => 500,
          :width => 300,
          :fields => fields
        )
        graph.add_data(
          :data => data_sales_02,
          :title => 'Sales 2002'
        )
        expect(graph.burn).to match /Created with SVG::Graph/
      end
    end
  end
end

describe '100% pie' do
  let(:fields) { %w(Internet TV Newspaper Magazine Radio) }
  let(:data1) { [0, 3, 0, 0, 0] }
  let(:data2) { [0, 6, 0, 0, 0] }
  let(:graph) do
    SVG::Graph::Pie.new(
      :height => 500,
      :width => 300,
      :fields => fields,
      :graph_title => "100% pie",
      :show_graph_title => true,
      :show_data_labels => true,
      :show_x_guidelines => true,
      :show_x_title => true,
      :x_title => "Time"
    ).tap do |graph|
      graph.add_data(
        :data => data1,
        :title => 'data1'
      )

      graph.add_data(
        :data => data2,
        :title => 'data2'
      )
    end
  end

  describe '#burn' do
    subject { graph.burn }

    it 'writes an SVG file without error' do # pro forma for examining file; we should remove once we understand better the nature of the SVG
      expect do
        File.open(File.expand_path("pie_100.svg",__dir__), "w") {|fout|
          fout.print(subject)
        }
      end.not_to raise_error
    end

    it 'contains a 100% marker' do
      expect(subject).to include 'TV 100%'
    end

    it 'contains a circle' do
      expect(subject).to include 'circle'
    end
  end
end
