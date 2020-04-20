require 'spec_helper'

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

  let(:graph) { dummy_graph.new({})}

  describe 'constructor' do
    subject { graph }

    it { is_expected.to be_a_kind_of described_class }
  end

  describe '#add_data' do
    shared_examples 'add_data' do
      shared_examples 'invalid data' do
        it 'raises an error' do
          expect { graph.add_data params }.to raise_error RuntimeError, /^No data provided/
        end
      end

      context 'no :data key' do
        let(:params) { Hash[*Faker::Lorem.words(rand(2..5) * 2)] }
        include_examples 'invalid data'
      end

      context ':data key is not an array' do
        let(:params) { {data: Faker::Lorem.sentence} }
        include_examples 'invalid data'
      end

      context 'string "data" key is also invalid' do
        let(:params) { {'data' => Faker::Lorem.words} }
        include_examples 'invalid data'
      end

      context 'valid data: :data key with array' do
        let(:params) { {data: Faker::Lorem.words} }

        it 'succeeds' do
          expect { graph.add_data params}.not_to raise_error
        end
      end
    end

    context 'starting empty' do
      include_examples 'add_data'
    end

    context 'starting with data already added' do
      let(:graph) { super().tap {|graph| graph.add_data data: Faker::Lorem.words } }
      include_examples 'add_data'
    end
  end

  describe '#to_iruby' do
    let(:graph) { super().tap {|graph| graph.add_data data: [1, 2, 3] } }

    it 'returns an HTML MIME type identifier and the SVG content of the graph' do
      expect(graph.to_iruby).to be == ['text/html', graph.burn_svg_only]
    end
  end
end
