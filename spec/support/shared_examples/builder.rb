# frozen_string_literal: true

RSpec.shared_examples "builder" do
  context "builder" do
    include_context "token class"

    before do
      token_class.claim(:uri, required: false)
      token_class.claim(:method, key: "verb", required: false)
    end

    let(:instance) { token_class.new(additional_options) }
    let(:additional_options) { {} }

    describe "#to_jwt", freeze_at: Time.utc(2018, 3, 4, 14) do
      subject { instance.to_jwt }

      it { is_expected.to eq token_with_expiry }

      context "when issuer is present" do
        let(:options) { super().merge(issuer: "service") }

        it { is_expected.to eq token_with_issuer_and_expiry }
      end

      context "when expiry is not present" do
        let(:options) { super().merge(expiry: nil) }

        it { is_expected.to eq token_without_claims }
      end

      context "when additional options are passed" do
        let(:additional_options) { { uri: "http://superhost.pl", verb: :post } }

        it { is_expected.to eq token_with_additional_options }
      end

      context "when key is not supplied" do
        let(:options) { super().merge(hmac: {}) }

        it "raises error" do
          expect { subject }
            .to raise_error(JWT::Token::MissingPrivateKey, "Private key required for signing tokens is missing!")
        end
      end
    end
  end
end
