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
    
    defp  apply_validation(true, account, transaction) do
        {:ok, account, transaction} 
    end
    
    defp  apply_validation(false, account, _transaction) do
        {:error, :inactive_account, account}
    end


end
