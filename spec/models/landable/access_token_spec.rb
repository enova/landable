require 'spec_helper'

module Landable
  describe AccessToken do
    it { should_not have_valid(:author_id).when(nil) }

    it 'generates an expiration timestamp before creation' do
      author = create :author
      permissions = { 'read' => 'true', 'edit' => 'true', 'publish' => 'true' }
      token  = AccessToken.create!(author: author, permissions: permissions)
      expect(token.expires_at).not_to be_nil
    end
  end
end
