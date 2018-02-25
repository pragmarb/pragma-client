RSpec.describe '/api/v1/categories' do
  describe 'GET /' do
    subject { -> { get api_v1_categories_path } }

    let!(:category) { create(:category) }

    it 'responds with 200 OK' do
      subject.call
      expect(last_response.status).to eq(200)
    end

    it 'responds with the categories' do
      subject.call
      expect(parsed_response).to match_array([
        a_hash_including('id' => category.id)
      ])
    end
  end

  describe 'GET /:id' do
    subject { -> { get api_v1_category_path(category) } }

    let!(:category) { create(:category) }

    it 'responds with 200 OK' do
      subject.call
      expect(last_response.status).to eq(200)
    end

    it 'responds with the category' do
      subject.call
      expect(parsed_response).to match(a_hash_including(
        'id' => category.id
      ))
    end
  end

  describe 'POST /' do
    subject { -> { post api_v1_categories_path, category.to_json } }

    let(:category) { attributes_for(:category) }

    it 'responds with 201 Created' do
      subject.call
      expect(last_response.status).to eq(201)
    end

    it 'creates a new category' do
      expect(subject).to change(Category, :count).by(1)
    end

    it 'responds with the new category' do
      subject.call
      expect(parsed_response).to match(a_hash_including(category.stringify_keys))
    end
  end

  describe 'PATCH /:id' do
    subject do
      proc do
        patch api_v1_category_path(category), new_category.to_json
        category.reload
      end
    end

    let!(:category) { create(:category) }
    let(:new_category) { attributes_for(:category) }

    it 'responds with 200 OK' do
      subject.call
      expect(last_response.status).to eq(200)
    end

    it 'updates the category' do
      subject.call
      expect(category.as_json).to match(a_hash_including(new_category.stringify_keys))
    end

    it 'responds with the updated category' do
      subject.call
      expect(parsed_response).to match(a_hash_including(new_category.stringify_keys))
    end
  end

  describe 'DELETE /:id' do
    subject { -> { delete api_v1_category_path(category) } }

    let!(:category) { create(:category) }

    it 'deletes the category' do
      expect(subject).to change(Category, :count).by(-1)
    end

    it 'responds with 204 No Content' do
      subject.call
      expect(last_response.status).to eq(204)
    end
  end
end
