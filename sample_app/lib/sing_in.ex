defmodule SampleApp.Signin do
  import SampleApp.Authentication
  
  def sign_in(email, password) do
    user = SampleApp.User.find_user_from_email(email)
    case authentication(user, password) do
      true -> {:ok, user}
         _ -> :error
    end
  end
end