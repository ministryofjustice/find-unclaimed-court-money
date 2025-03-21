RSpec.describe AnalyticsHelper do
  describe "#analytics_consent_cookie" do
    it "retrieves the analytics consent cookie" do
      expect(controller.cookies).to receive(:[]).with("fum_cookies_consent")
      helper.analytics_consent_cookie
    end
  end

  describe "#analytics_allowed?" do
    context "when consent cookie has not been set" do
      it { expect(helper.analytics_allowed?).to be false }
    end

    context "when consent cookie has been set" do
      before do
        allow(controller.cookies).to receive(:[]).with("fum_cookies_consent").and_return(value)
      end

      context "when cookies have been accepted" do
        let(:value) { ConsentCookie::ACCEPT }

        it { expect(helper.analytics_allowed?).to be true }
      end

      context "when cookies have been rejected" do
        let(:value) { ConsentCookie::REJECT }

        it { expect(helper.analytics_allowed?).to be false }
      end
    end
  end
end
