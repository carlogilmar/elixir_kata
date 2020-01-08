defmodule AuthorizerTest do
  use ExUnit.Case

  test "If exists models for account and transaction" do
    account = %Account{active_card: true, available_limit: 100}
    transaction = %Transaction{amount: 0, merchant: "Nubank", time: nil}
    assert account.active_card == true
    assert account.available_limit == 100
    assert transaction.amount == 0
    assert transaction.merchant == "Nubank"
    assert transaction.time == nil
  end

  test "No transaction should be accepted without a properly initialized account" do
    # Given
    account = :not_initialized
    transaction = %Transaction{amount: 100}
    # When
    res = Authorizer.valid_account_initialized({account, transaction})
    # I expect...
    assert res == {:error, :not_initialized, account}
  end

  test "A transaction should be accepted with a properly initialized account" do
    # Given
    account = %Account{active_card: true, available_limit: 100}
    transaction = %Transaction{amount: 100}
    # When
    res = Authorizer.valid_account_initialized({account, transaction})
    # I expect...
    assert res == {:ok, account, transaction}
  end

end
