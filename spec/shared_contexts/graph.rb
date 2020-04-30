RSpec.shared_context 'graph' do
  let(:graph_title) { Faker::Lorem.sentence }
  let(:width) { rand 600..1000 }
  let(:height) { rand 400..500 }

  let(:options) do
    {
      width: width,
      height: height,
      graph_title: graph_title,
    }
  end
end
