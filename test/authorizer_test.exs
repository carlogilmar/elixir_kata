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

  test "No transaction should be accepted when the card is not active" do
    # Given
    account = %Account{active_card: false, available_limit: 100}
    transaction = %Transaction{amount: 100}
    # Wen
    res = Authorizer.valid_account_active({:ok, account, transaction})
    # I expect
    assert res == {:error, :inactive_account, account}
  end

  test "transaction should be accepted when the card is active" do
    # Given
    account = %Account{active_card: true, available_limit: 100}
    transaction = %Transaction{amount: 100}
    # Wen
    res = Authorizer.valid_account_active({:ok, account, transaction})
    # I expect
    assert res == {:ok, account, transaction}
  end

  test "No transaction should be accepted when the card is not initialized" do
    # Given
    account = {:error, :not_initialized, :not_initialized}
    res = Authorizer.valid_account_active(account)
    assert res == account
  end

  test "The transaction amount exceed the available limit" do
    # Given
    account = %Account{active_card: true, available_limit: 150}
    # When
    transaction = %Transaction{amount: 200}
    # I expect
    res = Authorizer.validate_limit({:ok, account, transaction})

    assert res == {:error, :invalid_limit, account}
  end

  test "The transaction amount not exceed the available limit" do
    # Given
    account = %Account{active_card: true, available_limit: 150}
    # When
    transaction = %Transaction{amount: 100}
    # I expect
    res = Authorizer.validate_limit({:ok, account, transaction})

    assert res == {:ok, account, transaction}
  end

  test "If I get a previous error I expect the same error" do
    # Given
    error_response = {:error, :not_initialized, :not_initialized}
    res = Authorizer.validate_limit(error_response)
    assert res == error_response
  end

  test "Running the pipeline with success for authorize a transaction" do
    # Given
    account = %Account{active_card: true, available_limit: 150}
    # When
    transaction = %Transaction{amount: 700}
    # I expect
    res = Authorizer.authorize_transaction(account, transaction)
    assert res == {:ok, account, transaction}
  
  end
end
