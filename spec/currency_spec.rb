# encoding: utf-8

require "spec_helper"

describe Money::Currency do

  describe ".find" do
    it "returns currency matching given id" do
      with_custom_definitions do
        Money::Currency::TABLE[:usd] = JSON.parse(%Q({ "priority": 1, "iso_code": "USD", "iso_numeric": "840", "name": "United States Dollar", "symbol": "$", "subunit": "Cent", "subunit_to_unit": 100, "symbol_first": true, "html_entity": "$", "decimal_mark": ".", "thousands_separator": "," }))
        Money::Currency::TABLE[:eur] = JSON.parse(%Q({ "priority": 2, "iso_code": "EUR", "iso_numeric": "978", "name": "Euro", "symbol": "€", "subunit": "Cent", "subunit_to_unit": 100, "symbol_first": false, "html_entity": "&#x20AC;", "decimal_mark": ",", "thousands_separator": "." }))

        expected = Money::Currency.new(:eur)
        Money::Currency.find(:eur).should  == expected
        Money::Currency.find(:EUR).should  == expected
        Money::Currency.find("eur").should == expected
        Money::Currency.find("EUR").should == expected
      end
    end

    it "returns nil unless currency matching given id" do
      Money::Currency.find("ZZZ").should be_nil
    end
  end

  describe ".wrap" do
    it "returns nil if object is nil" do
      Money::Currency.wrap(nil).should == nil
      Money::Currency.wrap(Money::Currency.new(:usd)).should == Money::Currency.new(:usd)
      Money::Currency.wrap(:usd).should == Money::Currency.new(:usd)
    end
  end


  describe "#initialize" do
    it "lookups data from loaded config" do
      currency = Money::Currency.new("USD")
      currency.id.should                  == :usd
      currency.priority.should            == 1
      currency.iso_code.should            == "USD"
      currency.iso_numeric.should         == "840"
      currency.name.should                == "United States Dollar"
      currency.decimal_mark.should        == "."
      currency.separator.should           == "."
      currency.thousands_separator.should == ","
      currency.delimiter.should           == ","
    end

    it "raises UnknownMoney::Currency with unknown currency" do
      lambda { Money::Currency.new("xxx") }.should raise_error(Money::Currency::UnknownCurrency, /xxx/)
    end
  end

  describe "#<=>" do
    it "compares objects by priority" do
      Money::Currency.new(:cad).should > Money::Currency.new(:usd)
      Money::Currency.new(:usd).should < Money::Currency.new(:eur)
    end
  end

  describe "#==" do
    it "returns true if self === other" do
      currency = Money::Currency.new(:eur)
      currency.should == currency
    end

    it "returns true if the id is equal" do
      Money::Currency.new(:eur).should     == Money::Currency.new(:eur)
      Money::Currency.new(:eur).should_not == Money::Currency.new(:usd)
    end
  end

  describe "#eql?" do
    it "returns true if #== returns true" do
      Money::Currency.new(:eur).eql?(Money::Currency.new(:eur)).should be true
      Money::Currency.new(:eur).eql?(Money::Currency.new(:usd)).should be false
    end
  end

  describe "#hash" do
    it "returns the same value for equal objects" do
      Money::Currency.new(:eur).hash.should == Money::Currency.new(:eur).hash
      Money::Currency.new(:eur).hash.should_not == Money::Currency.new(:usd).hash
    end

    it "can be used to return the intersection of Currency object arrays" do
      intersection = [Money::Currency.new(:eur), Money::Currency.new(:usd)] & [Money::Currency.new(:eur)]
      intersection.should == [Money::Currency.new(:eur)]
    end
  end

  describe "#inspect" do
    it "works as documented" do
      Money::Currency.new(:usd).inspect.should ==
          %Q{#<Money::Currency id: usd, priority: 1, symbol_first: true, thousands_separator: ,, html_entity: $, decimal_mark: ., name: United States Dollar, symbol: $, subunit_to_unit: 100, iso_code: USD, iso_numeric: 840, subunit: Cent>}
    end
  end

  describe "#to_s" do
    it "works as documented" do
      Money::Currency.new(:usd).to_s.should == "USD"
      Money::Currency.new(:eur).to_s.should == "EUR"
    end
  end

  describe "#to_currency" do
    it "works as documented" do
      usd = Money::Currency.new(:usd)
      usd.to_currency.should == usd
    end

    it "doesn't create new symbols indefinitely" do
      expect {
        expect { Money::Currency.new("bogus") }.to raise_exception(Money::Currency::UnknownCurrency)
      }.to_not change{ Symbol.all_symbols.size }
    end
  end

  describe "#code" do
    it "works as documented" do
      Money::Currency.new(:usd).code.should == "$"
      Money::Currency.new(:azn).code.should == "AZN"
    end
  end


  def with_custom_definitions(&block)
    begin
      old = Money::Currency::TABLE.dup
      Money::Currency::TABLE.clear
      yield
    ensure
      silence_warnings do
        Money::Currency.const_set("TABLE", old)
      end
    end
  end

end
