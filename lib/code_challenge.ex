defmodule CodeChallenge do

  def authorize(account, transaction) do
  {account, transaction}
  |> Authorizer.valid_account_initialized()
  |> Authorizer.valid_account_active()
  |> Authorizer.validate_limit()
  |> Authorizer.validate_interval_limit()
  |> Authorizer.authorize_transaction()
  end

end
