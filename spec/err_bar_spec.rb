require 'spec_helper'

require_relative '../lib/SVG/Graph/ErrBar'

describe SVG::Graph::ErrBar do
  describe 'constructor' do
    let(:error_bars) { Faker::Lorem.words number: rand(1..5) }
    let(:fields) { Faker::Lorem.words number: rand(1..5) }
    let(:config) { {errorBars: error_bars, fields: fields} }

    subject { described_class.new config }

    shared_examples 'invalid unless non-empty array' do
      shared_examples 'invalid data' do
        it 'raises an error' do
          expect { subject }.to raise_error 'fields was not supplied or is empty'
        end
      end

      context 'not present' do
        let(:config) { super().tap {|config| config.delete field } }
        include_examples 'invalid data'
      end

      context 'not an array' do
        let(:config) { super().merge field => Faker::Lorem.sentence }
        include_examples 'invalid data'
      end

      context 'an empty array' do
        let(:config) { super().merge field => [] }
        include_examples 'invalid data'
      end
    end

    context ':errorBars' do
      let(:field) { :errorBars }
      include_examples 'invalid unless non-empty array'
    end

    context ':fields' do # TODO: this probably belongs in shared examples for BarBase
      let(:field) { :fields }
      include_examples 'invalid unless non-empty array'
    end

    context 'otherwise' do
      it { is_expected.to be_a_kind_of described_class }
      it { is_expected.to be_a_kind_of SVG::Graph::BarBase }
    end
  end

  describe '#burn' do
    let(:fields) { %w[Jan Feb] }
    let(:myarr1_mean) { 10 }
    let(:myarr1_confidence) { 1 }
    let(:myarr2_mean) { 20 }
    let(:myarr2_confidence) { 2 }
    let(:data_measure) { [myarr1_mean, myarr2_mean] }
    let(:err_measure) { [myarr1_confidence, myarr2_confidence] }

    let(:graph) do
      described_class.new(
        height: 500,
        width: 600,
        fields: fields,
        errorBars: err_measure
      ).tap do |graph|
        graph.add_data(
          data: data_measure,
          title: 'Sales 2002'
        )
      end
    end

    it 'returns a basic SVG graph' do
      expect do
        File.open(File.expand_path("err_bar.svg",__dir__), "w") {|fout|
          fout.print( graph.burn )
        }
      end.not_to raise_error
    end
  end
end
