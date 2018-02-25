RSpec.describe '/api/v1/articles' do
  describe 'GET /' do
    subject { -> { get api_v1_articles_path } }

    let!(:article) { create(:article) }

    it 'responds with 200 OK' do
      subject.call
      expect(last_response.status).to eq(200)
    end

    it 'responds with the articles' do
      subject.call
      expect(parsed_response).to match_array([
        a_hash_including('id' => article.id)
      ])
    end
  end

  describe 'GET /:id' do
    subject { -> { get api_v1_article_path(article) } }

    let!(:article) { create(:article) }

    it 'responds with 200 OK' do
      subject.call
      expect(last_response.status).to eq(200)
    end

    it 'responds with the article' do
      subject.call
      expect(parsed_response).to match(a_hash_including(
        'id' => article.id
      ))
    end
  end

  describe 'POST /' do
    subject { -> { post api_v1_articles_path, article.to_json } }

    let(:article) { attributes_for(:article) }

    it 'responds with 201 Created' do
      subject.call
      expect(last_response.status).to eq(201)
    end

    it 'creates a new article' do
      expect(subject).to change(Article, :count).by(1)
    end

    it 'responds with the new article' do
      subject.call
      expect(parsed_response).to match(a_hash_including(article.stringify_keys))
    end
  end

  describe 'PATCH /:id' do
    subject do
      proc do
        patch api_v1_article_path(article), new_article.to_json
        article.reload
      end
    end

    let!(:article) { create(:article) }
    let(:new_article) { attributes_for(:article) }

    it 'responds with 200 OK' do
      subject.call
      expect(last_response.status).to eq(200)
    end

    it 'updates the article' do
      subject.call
      expect(article.as_json).to match(a_hash_including(new_article.stringify_keys))
    end

    it 'responds with the updated article' do
      subject.call
      expect(parsed_response).to match(a_hash_including(new_article.stringify_keys))
    end
  end

  describe 'DELETE /:id' do
    subject { -> { delete api_v1_article_path(article) } }

    let!(:article) { create(:article) }

    it 'deletes the article' do
      expect(subject).to change(Article, :count).by(-1)
    end

    it 'responds with 204 No Content' do
      subject.call
      expect(last_response.status).to eq(204)
    end
  end
end
