defmodule SampleApp.Encryption do
  # password decrypt
  def decrypt(password) do
    Safetybox.decrypt(password)
  end

  # password encrypt
  def encrypt(password) do
    Safetybox.encrypt(password, :default)
  end
end