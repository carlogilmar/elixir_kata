defmodule Authorizer do
    def valid_account_initialized({:not_initialized, _transaction}) do
        {:error, :not_initialized, :not_initialized}
    end

    def valid_account_initialized({account, transaction}) do
        {:ok, account, transaction}
    end
end
