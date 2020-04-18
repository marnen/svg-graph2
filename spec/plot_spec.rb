require 'spec_helper'

require_relative '../lib/SVG/Graph/Plot'
require_relative '../lib/SVG/Graph/DataPoint'

# TODO: this file needs a lot of work!

describe SVG::Graph::Plot do
  before(:each) { DataPoint.reset_shape_criteria }

  describe '#burn' do
    it 'writes an SVG string including credits to SVG::Graph' do
      projection = [
       6, 11,    0, 5,   18, 7,   1, 11,   13, 9,   1, 2,   19, 0,   3, 13,
       7, 9
      ]
      actual = [
       0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
       15, 6,   4, 17,   2, 12
      ]

      graph = described_class.new({
        :height => 500,
        :width => 300,
        :key => true,
        :scale_x_integers => true,
        :scale_y_integers => true,
      })

      graph.add_data({
        :data => projection,
        :title => 'Projected',
      })

      graph.add_data({
        :data => actual,
        :title => 'Actual',
      })

      out=graph.burn()
      expect(out).to match /Created with SVG::Graph/
    end

    context 'plot axis too short' do
      it 'still writes a graph' do
        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
          :max_x_value => 9,
          :max_y_value => 9,
          :min_x_value => 6,
          :min_y_value => 6,
          :scale_x_divisions => 3,
          :scale_y_divisions => 3
        })

        graph.add_data({
          :data => [5,5,  12,12,  6,6,  9,9,  7,7,  10,10],
          :title => '10',
        })

        expect { File.write(File.expand_path("../plot_axis_short.svg", __FILE__), graph.burn) }.not_to raise_error
      end
    end

    context 'polyline connecting data points' do
      it 'draws the polyline by default' do
        actual = [
          0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
          15, 6,   4, 17,   2, 12
        ]

        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
        })

        graph.add_data({
          :data => actual,
          :title => 'Actual',
        })
        expect(graph.burn).to match /path.*class='line1'/
      end

      it 'does not draw the polyline if :show_lines is false' do
        actual = [
          0, 18,    8, 15,    9, 4,   18, 14,   10, 2,   11, 6,  14, 12,
          15, 6,   4, 17,   2, 12
        ]

        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
          :show_lines => false,
        })

        graph.add_data({
          :data => actual,
          :title => 'Actual',
        })

        expect(graph.burn).not_to match /path class='line1' d='M.* L.*'/
      end
    end

    context 'popups' do
      it 'rounds the values to integer by default' do
        actual = [
          0.1, 18,    8.55, 15.1234,    9.09876765, 4,
        ]

        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
          :add_popups => true,
          :number_format => "%s"
        })

        graph.add_data({
          :data => actual,
          :title => 'Actual',
        })

        out=graph.burn()
        File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)
        [
          ['(0.1, 18)', '(0, 18)'],
          ['(8.55, 15.1234)', '(9, 15)'], # round up
          ['(9.09876765, 4)', '(9, 4)']
        ].each do |unrounded, rounded|
          expect(out).not_to include unrounded
          expect(out).to include rounded
        end
      end

      it 'preserves decimal values if :round_popups is false' do
        actual = [
          0.1, 18,    8.55, 15.1234,    9.09876765, 4,
        ]

        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
          :add_popups => true,
          :round_popups => false,
          :number_format => "%s"
        })

        graph.add_data({
          :data => actual,
          :title => 'Actual',
        })

        out=graph.burn()
        File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)

        [
          ['(0.1, 18)', '(0, 18)'],
          ['(8.55, 15.1234)', '(9, 15)'], # round up
          ['(9.09876765, 4)', '(9, 4)']
        ].each do |unrounded, rounded|
          expect(out).to include unrounded
          expect(out).not_to include rounded
        end
      end

      it 'shows text descriptions if provided' do
        actual = [
          8.55, 15.1234,    9.09876765, 4,     0.1, 18,
        ]
        description = [
         'first',    'second',          'third',
        ]

        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
          :add_popups => true,
          :round_popups => false,
          :number_format => "%s"
        })

        graph.add_data({
          :data => actual,
          :title => 'Actual',
          :description => description,
        })

        out=graph.burn()
        File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)
        [
          ['(8.55, 15.1234, first)', '(8.55, 15.1234)'],
          ['(9.09876765, 4, second)', '(9.09876765, 4)'],
          ['(0.1, 18, third)', '(0.1, 18)']
        ].each do |with_string, without_string|
          expect(out).to include with_string
          expect(out).not_to include without_string
        end
      end

      it 'combines different shapes based on the descriptions given' do
        actual = [
         8.55, 15.1234,         9.09876765, 4,                  2.1, 18,
        ]
        description = [
         'one is a circle',     'two is a rectangle',           'three is a rectangle with strikethrough',
        ]

        # multiple array of the form
        # [ regex ,
        #   lambda taking three arguments (x,y, line_number for css)
        #     -> return value of the lambda must be an array: [svg tag name,  Hash with keys "points" and "class"]
        # ]
        DataPoint.configure_shape_criteria(
          [/^t.*/, lambda{|x,y,line| ['polygon', {
              "points" => "#{x-1.5},#{y+2.5} #{x+1.5},#{y+2.5} #{x+1.5},#{y-2.5} #{x-1.5},#{y-2.5}",
              "class" => "dataPoint#{line}"
            }]
          }],
          [/^three.*/, lambda{|x,y,line| ['line', {
              "x1" => "#{x-4}",
              "y1" => y.to_s,
              "x2" => "#{x+4}",
              "y2" => y.to_s,
              "class" => "axis"
            }]
          },"OVERLAY"],
        )
        graph = described_class.new({
          :height => 500,
          :width => 300,
          :key => true,
          :scale_x_integers => true,
          :scale_y_integers => true,
          :add_popups => true,
          :round_popups => false,
        })

        graph.add_data({
          :data => actual,
          :title => 'Actual',
          :description => description,
        })

        out=graph.burn()
        File.write(File.expand_path("plot_#{__method__}.svg", __dir__), out)
        expect(out).to match /polygon.*points/
        expect(out).to match /line.*axis/
      end

      context 'radius' do
        it 'is 10 by default' do
          actual = [
           1, 1,    5, 5,     10, 10,
          ]
          description = [
           'first',    'second',          'third',
          ]

          graph = described_class.new({
            :height => 500,
            :width => 300,
            :key => true,
            :scale_x_integers => true,
            :scale_y_integers => true,
            :add_popups => true,
            :round_popups => false,
          })

          graph.add_data({
            :data => actual,
            :title => 'Actual',
            :description => description,
          })

          out=graph.burn()
          expect(out).to match /circle .*r='10'/
          expect(out).to match /circle .*onmouseover=.*/
        end

        it 'can be overridden by specifying :popup_radius' do
          actual = [
           1, 1,    5, 5,     10, 10,
          ]
          description = [
           'first',    'second',          'third',
          ]

          graph = described_class.new({
            :height => 500,
            :width => 300,
            :key => true,
            :scale_x_integers => true,
            :scale_y_integers => true,
            :add_popups => true,
            :round_popups => false,
            :popup_radius => 1.23
          })

          graph.add_data({
            :data => actual,
            :title => 'Actual',
            :description => description,
          })

          out=graph.burn()
          expect(out).to match /circle .*r='1.23'/
          expect(out).to match /circle .*onmouseover=.*/
        end
      end
    end
  end
end
