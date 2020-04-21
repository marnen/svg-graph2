require 'spec_helper'

require_relative '../lib/SVG/Graph/DataPoint'

RSpec.describe DataPoint do
  before(:each) { described_class.reset_shape_criteria }

  describe '#shape' do
    let(:x) { rand(50.0..150.0) }
    let(:y) { rand(50.0..150.0) }
    let(:default_radius) { '2.5' }
    let(:series) { rand 1..10 }
    let(:css_class) { "dataPoint#{series}" }
    let(:args) { [] }

    let(:default_circle) do
      ['circle', {
        "cx" => x,
        "cy" => y,
        "r" => default_radius,
        "class" => css_class
      }]
    end

    subject { described_class.new(x, y, series).shape *args }

    shared_examples 'default circle' do
      it 'returns an array containing a circle with the given coordinates, radius 2.5, and the class of the given data series' do
        expect(subject).to be == [default_circle]
      end
    end

    context 'no description' do
      include_examples 'default circle'
    end

    context 'description' do
      let(:description) { 'description' }
      let(:args) { super() + [description] }

      context 'no criteria' do
        include_examples 'default circle'
      end

      context 'criteria' do
        let(:width) { rand(1..10).to_s }
        let(:height) { rand(1..10).to_s }
        let(:words) { Faker::Lorem.words number: rand(2..5) }

        before(:each) { described_class.configure_shape_criteria *criteria }

        context 'single criterion' do
          context 'description matches regex in criterion' do
            let(:regex) { Regexp.new words.sample }
            let(:description) { words.join ' ' }
            let(:class_prefix) { Faker::Lorem.word }
            let(:generator) do
              -> (x, y, line) {
                ['rect', {
                  "x" => x,
                  "y" => y,
                  "width" => width,
                  "height" => height,
                  "class" => [class_prefix, line].join('-')
                }]
              }
            end
            let(:criteria) { [[regex, generator]] }

            it 'is an array containing the shape generated by the corresponding lambda' do
              expect(subject).to be == [generator.call(x, y, series)]
            end
          end
        end

        context 'multiple criteria' do
          let(:shapes) { Faker::Lorem.words number: words.length }
          let(:criteria) { words.zip(shapes).map {|(word, shape)| [Regexp.new(word), -> (_, _, _) { shape } ] } }
          let(:description) { words.shuffle.join ' ' }

          it 'returns the generated shapes in the order of the criteria' do
            expect(subject).to be == shapes
          end

          context 'with overlay match' do
            let(:overlay_shape) { Faker::Lorem.word }
            let(:criteria) { [[Regexp.new(words.first), lambda{|x,y,line| overlay_shape }, DataPoint::OVERLAY]] }

            it 'returns the overlay match after all the other shapes' do
              expect(subject.last).to be == overlay_shape
            end

            it 'does not prevent generation of default shape' do
              expect(subject.first).to be == default_circle
            end
          end
        end
      end
    end
  end
end
