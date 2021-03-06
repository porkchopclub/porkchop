require 'rails_helper'

RSpec.describe ScoreboardsController, type: :controller do
  describe "GET show" do
    subject { get :show, params: { id: table_id } }

    before { sign_in create(:admin_player) }

    context "when the table does exist" do
      let(:table_id) { create(:table).id }
      it { is_expected.to have_http_status :ok }
      it { is_expected.to render_template :show }
    end

    context "when the table doesn't exist" do
      let(:table_id) { 2277 }
      it "raises an error" do
        expect { subject }.
          to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end
