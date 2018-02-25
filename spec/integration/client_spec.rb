# frozen_string_literal: true

RSpec.describe 'Client Integration' do
  around do |example|
    VCR.use_cassette('client_integration', record: :new_episodes) do
      example.run
    end
  end

  describe '.all' do
    it 'returns all the records' do
      expect(BlogApi::Article.all.to_a.size).to eq(62)
    end
  end

  describe '.retrieve' do
    it 'returns the record' do
      expect(BlogApi::Article.retrieve(5).title).to eq('Article 5')
    end
  end

  describe '#save' do
    context 'when the record does not exist' do
      it 'creates a new record' do
        article = BlogApi::Article.new(category: 1, title: 'Hello world')
        article.save
        expect(article.id).to eq(64)
      end
    end

    context 'when the record already exists' do
      it 'updates the record' do
        article = BlogApi::Article.retrieve(5)
        article.title = 'New title'
        article.save
        expect(article.title).to eq('New title')
      end
    end
  end

  describe '#delete' do
    it 'deletes the record' do
      article = BlogApi::Article.retrieve(5)
      article.delete
      expect { article.reload }.to raise_error(RestClient::NotFound)
    end
  end

  describe '#reload' do
    it 'reloads the record' do
      article = BlogApi::Article.retrieve(6)
      article.title = 'foo'
      article.reload
      expect(article.title).to eq('Article 6')
    end
  end

  describe '#update' do
    it 'updates the record' do
      article = BlogApi::Article.retrieve(5)
      article.update(title: 'New title')
      expect(article.title).to eq('New title')
    end
  end
end
