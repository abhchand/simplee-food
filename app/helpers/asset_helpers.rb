require 'json'

helpers do
  def asset_manifest
    @asset_manifest ||=
      JSON.parse(File.read(APP_ROOT.join('public', 'manifest.json')))
  end

  def css_asset_path(name)
    '/' + asset_manifest[name.to_s + '.css.css']
  end

  def js_asset_path(name)
    '/' + asset_manifest[name.to_s + '.js']
  end

  def recipe_image_placeholder
    @recipe_image_placeholder ||=
      begin
        img_data = File.read(APP_ROOT.join('public', 'images', 'no-image.jpg'))
        'image/jpeg;base64,' + Base64.encode64(img_data)
      end
  end

  def svg_icon(name)
    @svg_icons ||= {}
    @svg_icons[name.to_sym] ||= APP_ROOT.join(
      'public',
      'images',
      'icons',
      "#{name}.svg"
    ).read
  end
end
