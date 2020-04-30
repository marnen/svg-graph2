require_relative 'graph'

RSpec.shared_context 'bar graph' do
  include_context 'graph' do
    let(:x_title) { Faker::Lorem.sentence }
    let(:fields) { Faker::Lorem.words number: length }
    let(:y_title) { Faker::Lorem.sentence }

    let(:extra_options) { {} }

    before(:each) do
      options.merge!(
        stack: :side,  # the stack option is valid for Bar graphs only
        fields: fields,
        scale_integers: true,
        x_title: x_title,
        x_title_location: :end,
        y_title: y_title,
        y_title_location: :end,
        no_css: true
      ).merge! extra_options
    end
  end
end
