defmodule SafetyboxSample do
  def encrypt(password) do
    Safetybox.encrypt(password)
  end

  def authentication(_userid, _user_name, password) do
    encrypt_password = "" # DBからユーザデータを取得する処理が入る
    Safetybox.is_decrypted(password, encrypt_password)
  end
end