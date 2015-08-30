defmodule SampleApp.Authentication do
  def authentication(user, password) do
    case user do
      nil -> false
        _ ->
          password == SampleApp.Encryption.decrypt(user.password_digest)
    end
  end
end