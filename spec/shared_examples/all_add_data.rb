RSpec.shared_examples 'all add_data' do
  shared_examples 'add_data' do
    shared_examples 'invalid data' do
      it 'raises an error' do
        expect { graph.add_data params }.to raise_error RuntimeError, /^No data provided/
      end
    end

    let(:even_number) { rand(2..5) * 2 }

    context 'no :data key' do
      let(:params) { Hash[*Faker::Lorem.words(even_number)] }
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
      let(:params) { {data: Faker::Lorem.words(even_number)} }

      it 'succeeds' do
        expect { graph.add_data params}.not_to raise_error
      end
    end
  end

  context 'starting empty' do
    include_examples 'add_data'
  end

  context 'starting with data already added' do
    let(:graph) { super().tap {|graph| graph.add_data data: Faker::Lorem.words(even_number) } }
    include_examples 'add_data'
  end
end
