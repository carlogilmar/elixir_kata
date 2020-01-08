defmodule Authorizer do
  def valid_account_initialized({:not_initialized, _transaction}) do
    {:error, :not_initialized, :not_initialized}
  end

  def valid_account_initialized({account, transaction}) do
    {:ok, account, transaction}
  end

  def valid_account_active({:ok, account, transaction}) do
    apply_validation(account.active_card, account, transaction)
  end

  def valid_account_active({:error, msg, account}) do
    {:error, msg, account}
  end

  def validate_limit({:ok, account, transaction}) do
    validation = account.available_limit < transaction.amount

    case validation do
      true -> {:error, :invalid_limit, account}
      false -> {:ok, account, transaction}
    end
  end

  def validate_limit({:error, msg, account}) do
    {:error, msg, account}
  end

  defp apply_validation(true, account, transaction) do
    {:ok, account, transaction}
  end

  defp apply_validation(false, account, _transaction) do
    {:error, :inactive_account, account}
  end

  def validate_interval_limit({:ok, account, transaction}) do
    case length(account.authorized_transactions) do
      t when t in 0..2 -> {:ok, account, transaction}
      _ -> 
        [third | [second | [first | _tail]]] = account.authorized_transactions

        first_diff = NaiveDateTime.diff(first.time, transaction.time)
        second_diff = NaiveDateTime.diff(second.time, transaction.time)
        third_diff = NaiveDateTime.diff(third.time, transaction.time)

        first_comp = first_diff < 120
        second_comp = second_diff < 120
        third_comp = third_diff < 120

        case {first_comp, second_comp, third_comp} do
         {true, true, true} -> {:error, :interval_limit, account}
         {false, _, _} -> {:ok, account, transaction}
        end

    end
  end

  def validate_interval_limit({:error, msg, account}) do
    {:error, msg, account}
  end

  def authorize_transaction({:ok, account, transaction}) do
    new_limit = account.available_limit - transaction.amount
    transactions = [transaction] ++ account.authorized_transactions 
    account_updated = 
      %{account | 
                  available_limit: new_limit, 
                  authorized_transactions: transactions}
    {:ok, account_updated}
  end

  def authorize_transaction({:error, msg, account}) do
    {:error, msg, account}
  end

  def authorize(account, transaction) do
  {account, transaction}
  |> valid_account_initialized()
  |> valid_account_active()
  |> validate_limit() 
  |> validate_interval_limit()
  |> authorize_transaction()
  end

end
