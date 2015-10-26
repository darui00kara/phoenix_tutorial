defmodule SampleApp.Encryption do
  def decrypt(password) do
    Safetybox.decrypt(password)
  end

  def encrypt(password) do
    Safetybox.encrypt(password, :default)
  end
end