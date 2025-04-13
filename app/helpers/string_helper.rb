helpers do
  def truncate_str(str, len = 20)
    str.length > len ? str[0, (len - 3)] + '...' : str
  end
end
