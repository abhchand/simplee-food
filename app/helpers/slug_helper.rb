module SlugHelper
  def to_slug(str)
    slug = str.dup
    slug = slug.downcase.strip

    source = "àáäâèéëêìíïîòóöôùúüûñç·/_,:;?@&=+$.!~'()#".split('')
    target = 'aaaaeeeeiiiioooouuuunc-------------------'.split('')

    source.each_with_index { |s, idx| slug.gsub!(s, target[idx]) }

    # Collapse whitespace and dashes
    slug = slug.gsub(/\s+/, '-').gsub(/-+/, '-')

    # Remove leading or trailing dashes
    slug.gsub(/\A-/, '').gsub(/-\z/, '')
  end
end
