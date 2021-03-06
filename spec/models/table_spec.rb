require 'rails_helper'

RSpec.describe Table, type: :model do
  it { is_expected.to have_many :matches }
  it { is_expected.to validate_presence_of :name }

  describe "#active_players" do
    subject { table.active_players }

    let!(:active_player_one) { create :active_player }
    let!(:active_player_two) { create :active_player }
    let!(:inactive_player) { create :player }

    context "when it is the default table" do
      let(:table) { create :default_table }
      it { is_expected.to contain_exactly active_player_one, active_player_two }
    end

    context "when it is not the default table" do
      let(:table) { create :table }
      it { is_expected.to be_empty }
    end
  end

  describe "#ongoing_match" do
    subject { table.ongoing_match }

    let(:table) { create :table }

    context "when there is no ongoing match" do
      it { is_expected.to be_nil }
    end

    context "when there is an ongoing match" do
      let!(:other_table_match) { create :new_match }
      let!(:finished_match) { create :complete_match, table: table }
      let!(:ongoing_match) { create :new_match, table: table }
      it { is_expected.to eq ongoing_match }
    end

    context "when there are multiple ongoing matches" do
      let!(:other_table_match) { create :new_match }
      let!(:finished_match) { create :complete_match, table: table }
      let!(:ongoing_match_one) { create :new_match, table: table, created_at: 2.minutes.ago }
      let!(:ongoing_match_two) { create :new_match, table: table, created_at: 1.minute.ago }
      let!(:ongoing_match_three) { create :new_match, table: table, created_at: 3.minutes.ago }

      it { is_expected.to eq ongoing_match_three }
    end
  end

  describe "upcoming matches" do
    subject { table.upcoming_matches }

    let(:table) { create :table }

    context "when there are no matches happening" do
      let!(:finished_match) { create :complete_match, table: table }
      it { is_expected.to eq [] }
    end

    context "when there is a match happening but none upcoming" do
      let!(:other_table_match) { create :new_match }
      let!(:finished_match) { create :complete_match, table: table }
      let!(:ongoing_match) { create :new_match, table: table }
      it { is_expected.to eq [] }
    end

    context "when there are matches upcoming" do
      let!(:other_table_match) { create :new_match }
      let!(:finished_match) { create :complete_match, table: table }
      let!(:ongoing_match_one) { create :new_match, table: table, created_at: 2.minutes.ago }
      let!(:ongoing_match_two) { create :new_match, table: table, created_at: 1.minute.ago }
      let!(:ongoing_match_three) { create :new_match, table: table, created_at: 3.minutes.ago }
      it { is_expected.to eq [ongoing_match_one, ongoing_match_two] }
    end
  end
end
