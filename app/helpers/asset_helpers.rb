helpers do
  def svg_icon(name)
    @svg_icons ||= {}
    @svg_icons[name.to_sym] ||=
      APP_ROOT.join("public", "images", "icons", "#{name}.svg").read
  end
end
