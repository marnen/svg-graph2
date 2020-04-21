require 'spec_helper'

require_relative '../lib/svggraph'
require_relative 'shared_examples/all_add_data'

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
  let(:config) { {} }
  let(:graph) { dummy_graph.new(config)}

  describe 'constructor' do
    subject { graph }

    it { is_expected.to be_a_kind_of described_class }
  end

  describe '#add_data' do
    include_examples 'all add_data'
  end

  context 'operations on graphs with data' do
    let(:graph) { super().tap {|graph| graph.add_data data: Faker::Lorem.words } }

    describe '#clear_data' do
      it 'clears the data' do
        graph.clear_data
        expect { graph.burn }.to raise_error 'No data available'
      end
    end

    context 'SVG output' do
      let(:xml) { REXML::Document.new subject }

      describe '#burn' do
        subject { graph.burn }

        shared_examples 'basic SVG document' do
          it 'returns an XML document' do
            expect(subject).to start_with REXML::XMLDecl.new.to_s
          end

          it 'uses the SVG 1.0 doctype' do
            expect(xml.doctype.to_s).to be == REXML::DocType.new(['svg', REXML::DocType::PUBLIC, '-//W3C//DTD SVG 1.0//EN', 'http://www.w3.org/TR/2001/REC-SVG-20010904/DTD/svg10.dtd']).to_s
          end

          it 'contains an <svg> element as root' do
            expect(xml.root.name).to be == 'svg'
          end
        end

        context 'not compressed' do
          include_examples 'basic SVG document'
        end

        context 'compressed', pending: 'looks like the compressed data may not be written correctly' do
          let(:config) { super().merge compress: true }

          subject { Zlib::Inflate.inflate super() }

          include_examples 'basic SVG document'
        end
      end

      describe '#burn_svg_only' do
        subject { graph.burn_svg_only }

        it 'contains an <svg> element as root' do
          expect(xml.root.name).to be == 'svg'
        end

        it 'does not contain an XML declaration' do
          expect(subject).not_to include '?xml'
        end

        it 'does not contain a doctype declaration' do
          expect(subject).not_to include 'DOCTYPE'
        end
      end
    end

    describe '#to_iruby' do
      it 'returns an HTML MIME type identifier and the SVG content of the graph' do
        expect(graph.to_iruby).to be == ['text/html', graph.burn_svg_only]
      end
    end
  end
end
