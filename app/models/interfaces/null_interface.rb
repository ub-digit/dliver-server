class NullInterface
  def method_missing(method, *args)
    return ""
  end
end
