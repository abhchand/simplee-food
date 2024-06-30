# Updates a `Recipe` instance based on new `params`.
# This can also be used to create a Recipe if pass a newly instantiated
# `Recipe.new` object.
#
class RecipeUpdateService
  class UpdateError < StandardError
  end

  MAX_IMAGE_HEIGHT = 2_000
  MAX_IMAGE_WIDTH = 2_000

  # params should be of the form:
  #
  # {
  #   "recipe": {
  #     "image": {
  #       "filename": "filename.jpg",
  #       "type": "image/jpeg",
  #       "name": "recipe[image]",
  #       "tempfile": "#\\u003cFile:0x00007f1c44931d38\\u003e",
  #       "head": "Content-Disposition: ...."
  #     },
  #     "name": "....",
  #     "source_url": "....",
  #     "serving_size": "...",
  #     "ingredients": {
  #       "0": "...",
  #       "1": "...",
  #     },
  #     "instructions": {
  #       "0": "...",
  #       "1": "...",
  #     },
  #     "tag_ids": [
  #       "...",
  #     ],
  #     "tag_names": [
  #       "...",
  #     ]
  #   }
  # }
  def initialize(recipe, params = {})
    @recipe = recipe
    @params = params
  end

  def call
    validate_params!

    # Update attributes on this recipe
    @recipe.attributes = attributes
    raise_error(@recipe.errors.full_messages[0]) unless @recipe.save

    # Add/Remove tags on this recipe
    (new_tags - cur_tags).each { |tag| @recipe.add_tag(tag) }
    (cur_tags - new_tags).each { |tag| @recipe.rm_tag(tag) }
    Tag.remove_all_unused!
  end

  private

  # Build a set of attributes that will be used to update the Recipe record
  #
  # We fully over-write existing attributes with any new attributes sent in
  # the params.
  #
  # Thee only exception to this is the image. If a `nil` value is sent in the
  # params, we don't overwrite it.
  def attributes
    return @attributes if @attributes

    @attributes = {
      name: @params[:recipe][:name],
      source_url: @params[:recipe][:source_url],
      serving_size: @params[:recipe][:serving_size],
      ingredients: (@params[:recipe][:ingredients] || {}).values,
      steps: (@params[:recipe][:instructions] || {}).values
    }

    # assumption: `image_valid?` should have already been called before this
    @attributes.merge!(image: image) if image?

    @attributes
  end

  def image
    # e.g. "image/jpeg"
    mime_type = @params[:recipe][:image][:type]
    body = File.read(@params[:recipe][:image][:tempfile])

    "#{mime_type};base64,#{Base64.encode64(body)}"
  end

  def image?
    @params.dig(:recipe, :image, :tempfile).present?
  end

  def image_valid?
    return true unless image?

    width, height = *FastImage.size(@params[:recipe][:image][:tempfile].path)
    width < MAX_IMAGE_WIDTH && height < MAX_IMAGE_HEIGHT
  end

  # "Current tags" are the tags that already exist on the recipe, before update
  def cur_tags
    @cur_tags ||= @recipe.tags
  end

  def new_tags
    # "New tags" are the tags that we want to exist on the recipe, after update
    #
    # This is a combination of 2 data sets:
    #   1. Any existing `Tag`s specified in `tag_ids`
    #   2. Any to-be-created `Tag`s specified in `tag_names`
    #
    # The latter represents brand new tags that we'd like to create and add
    # to the recipe in one action, so we create the `Tag` below.
    @new_tags ||=
      Tag.where(id: @params[:recipe][:tag_ids] || []).to_a +
        (@params[:recipe][:tag_names] || []).map do |name|
          Tag.find_or_create_by(name: name)
        end
  end

  def raise_error(msg)
    raise UpdateError.new(msg)
  end

  def validate_params!
    unless image_valid?
      raise_error(
        "Image must be less than #{MAX_IMAGE_WIDTH}x#{MAX_IMAGE_HEIGHT}"
      )
    end
  end
end
