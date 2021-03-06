require File.expand_path(File.dirname(__FILE__) + "/../spec_helper")
require File.expand_path(File.dirname(__FILE__) + "/client_api/spec_helper")

describe Braintree::UsBankAccount do
  describe "self.find" do
    it "returns a UsBankAccount" do
      customer = Braintree::Customer.create!
      nonce = generate_valid_us_bank_account_nonce

      result = Braintree::PaymentMethod.create(
        :payment_method_nonce => nonce,
        :customer_id => customer.id
      )
      result.should be_success

      us_bank_account = Braintree::UsBankAccount.find(result.payment_method.token)
      us_bank_account.should be_a(Braintree::UsBankAccount)
      us_bank_account.routing_number.should == "123456789"
      us_bank_account.last_4.should == "1234"
      us_bank_account.account_type.should == "checking"
      us_bank_account.account_description.should == "PayPal Checking - 1234"
      us_bank_account.account_holder_name.should == "Dan Schulman"
    end

    it "raises if the payment method token is not found" do
      expect do
        Braintree::UsBankAccount.find(generate_invalid_us_bank_account_nonce)
      end.to raise_error(Braintree::NotFoundError)
    end
  end

  context "self.sale" do
    it "creates a transaction using a us bank account and returns a result object" do
      customer = Braintree::Customer.create!
      nonce = generate_valid_us_bank_account_nonce

      result = Braintree::PaymentMethod.create(
        :payment_method_nonce => nonce,
        :customer_id => customer.id
      )
      result.should be_success

      result = Braintree::UsBankAccount.sale(result.payment_method.token, :merchant_account_id => "us_bank_merchant_account", :amount => "100.00")

      result.success?.should == true
      result.transaction.amount.should == BigDecimal.new("100.00")
      result.transaction.type.should == "sale"
      us_bank_account = result.transaction.us_bank_account_details
      us_bank_account.routing_number.should == "123456789"
      us_bank_account.last_4.should == "1234"
      us_bank_account.account_type.should == "checking"
      us_bank_account.account_description.should == "PayPal Checking - 1234"
      us_bank_account.account_holder_name.should == "Dan Schulman"
    end
  end

  context "self.sale!" do
    it "creates a transaction using a us bank account and returns a result object" do
      customer = Braintree::Customer.create!
      nonce = generate_valid_us_bank_account_nonce

      result = Braintree::PaymentMethod.create(
        :payment_method_nonce => nonce,
        :customer_id => customer.id
      )
      result.should be_success

      transaction = Braintree::UsBankAccount.sale!(result.payment_method.token, :merchant_account_id => "us_bank_merchant_account", :amount => "100.00")

      transaction.amount.should == BigDecimal.new("100.00")
      transaction.type.should == "sale"
      us_bank_account = transaction.us_bank_account_details
      us_bank_account.routing_number.should == "123456789"
      us_bank_account.last_4.should == "1234"
      us_bank_account.account_type.should == "checking"
      us_bank_account.account_description.should == "PayPal Checking - 1234"
      us_bank_account.account_holder_name.should == "Dan Schulman"
    end

    it "does not creates a transaction using a us bank account and returns raises an exception" do
      expect do
        Braintree::UsBankAccount.sale!(generate_invalid_us_bank_account_nonce, :merchant_account_id => "us_bank_merchant_account", :amount => "100.00")
      end.to raise_error(Braintree::ValidationsFailed)
    end
  end
end
