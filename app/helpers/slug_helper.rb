module SlugHelper
  # Attempts to slug-ify the `name` and store in the `slug` field
  #
  # e.g. 'Idli and Rasam' becomes 'idli-and-rasam'
  #
  # If conflicts exist, we add a suffix `-2`, `-3`, etc...
  def calculate_slug
    # If we're updating and name didn't change - don't do anything
    return if persisted? && !name_changed?

    # `name` should always be present, but in case it's not present, let
    # validations catch the error instead of running into an error here.
    return self[:slug] = nil if name.nil?

    base_slug = to_slug(name)
    suffix = 1

    # Keep looping till we find a valid slug name we can use
    loop do
      # We never use `-1` as a suffix. We start with `-2`, if needed
      slug = [base_slug, suffix == 1 ? nil : suffix].compact.join('-')
      record = self.class.find_by_slug(slug)

      if record.nil?
        self[:slug] = slug
        break
      end

      suffix += 1
    end
  end

  def to_slug(str)
    slug = str.dup
    slug = slug.downcase.strip

    source = "àáäâèéëêìíïîòóöôùúüûñç·/_,:;?@&=+$.!~'()#|".split('')
    target = 'aaaaeeeeiiiioooouuuunc--------------------'.split('')

    source.each_with_index { |s, idx| slug.gsub!(s, target[idx]) }

    # Collapse whitespace and dashes
    slug = slug.gsub(/\s+/, '-').gsub(/-+/, '-')

    # Remove leading or trailing dashes
    slug.gsub(/\A-/, '').gsub(/-\z/, '')
  end
end
