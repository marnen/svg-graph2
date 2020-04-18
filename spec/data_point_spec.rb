require_relative '../lib/SVG/Graph/DataPoint'

RSpec.describe DataPoint do
  before(:each) { described_class.reset_shape_criteria }

  describe '#shape' do
    let(:x) { 100.0 }
    let(:y) { 100.0 }
    let(:series) { 1 }
    let(:args) { [] }

    subject { described_class.new(x, y, series).shape(*args) }

    context 'no description' do
      it 'is a circle with radius 2.5' do
        expect(subject).to be == [['circle', {
          "cx" => 100.0,
          "cy" => 100.0,
          "r" => "2.5",
          "class" => "dataPoint1"
        }]]
      end
    end

    context 'description' do
      let(:description) { 'description' }
      let(:args) { super() + [description] }

      context 'no criteria' do
        it 'is a circle with radius 2.5' do
          expect(subject).to be == [['circle', {
            "cx" => 100.0,
            "cy" => 100.0,
            "r" => "2.5",
            "class" => "dataPoint1"
          }]]
        end
      end

      context 'criteria' do
        let(:y) { 50.0 }
        let(:series) { 2 }

        before(:each) { described_class.configure_shape_criteria *criteria }

        context 'single criterion' do
          context 'description matches regex in criteria' do
            let(:description) { 'rectangle' }
            let(:criteria) do
              [[/angle/, lambda{|x,y,line| ['rect', {
                "x" => x,
                "y" => y,
                "width" => "5",
                "height" => "5",
                "class" => "dataPoint#{line}"
              }]}]]
            end

            it 'is the shape described by the corresponding lambda' do
              expect(subject).to be == [['rect', {
                "x" => 100.0,
                "y" => 50.0,
                "width" => "5",
                "height" => "5",
                "class" => "dataPoint2"
              }]]
            end
          end
        end

        context 'multiple criteria' do
          let(:criteria) do
            [
              [/3/, lambda{|x,y,line| "three" }],
              [/2/, lambda{|x,y,line| "two" }],
              [/1/, lambda{|x,y,line| "one" }]
            ]
          end
          let(:description) { '1 3 2' }

          it 'returns the generated shapes in the order of the criteria' do
            expect(subject).to be == %w[three two one]
          end

          context 'with overlay match' do
            let(:criteria) { [[/3/, lambda{|x,y,line| "three" }, DataPoint::OVERLAY]] }

            it 'returns the overlay match last' do
              expect(subject.last).to be == 'three'
            end

            it 'does not prevent generation of default shape' do
              expect(subject.first).to be == ['circle', {
                "cx" => 100.0,
                "cy" => 50.0,
                "r" => "2.5",
                "class" => "dataPoint2"
              }]
            end
          end
        end
      end
    end
  end
end
