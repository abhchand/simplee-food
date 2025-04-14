# Creates or Updates a `Recipe` instance
#
class RecipeUpdateService
  class UpdateError < StandardError
  end

  # Initialize the class with a `Recipe` instance and the params that should
  # be used to create/update the instance.
  #
  # You can pass a non-persisted Recipe record (e.g. `Recipe.new`) to create
  # a new record.
  #
  # `params` should be an indifferent Hash of the form:
  #
  #   {
  #     recipe: {
  #       image: {
  #         filename: 'filename.jpg',
  #         type: 'image/jpeg',
  #         name: 'recipe[image]',
  #         tempfile: '#\\u003cFile:0x00007f1c44931d38\\u003e',
  #         head: 'Content-Disposition: ....'
  #       },
  #       name: '....',
  #       source_url: '....',
  #       serving_size: '...',
  #       ingredients: {
  #         0: '...',
  #         1: '...',
  #       },
  #       instructions: {
  #         0: '...',
  #         1: '...',
  #       },
  #       tag_ids: [
  #         '...',
  #       ],
  #       tag_names: [
  #         '...',
  #       ]
  #     }
  #   }
  #
  # @param recipe [Recipe] the `Recipe` model instance. If persisted, it will
  #   be updated. If not persisted, it will create a new record.
  # @param params [Hash] the params containing attributes to create or update
  #   the record, in the format described above.
  def initialize(recipe, params = {})
    @recipe = recipe
    @params = params
  end

  def call
    # Update attributes on this recipe
    @recipe.attributes = attributes
    raise UpdateError.new(@recipe.errors.full_messages[0]) unless @recipe.save

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
  # params, we don't clear the image.
  def attributes
    return @attributes if @attributes

    @attributes = {
      name: @params[:recipe][:name],
      source_url: @params[:recipe][:source_url],
      serving_size: @params[:recipe][:serving_size],
      ingredients: (@params[:recipe][:ingredients] || {}).values,
      instructions: (@params[:recipe][:instructions] || {}).values
    }

    # nilify any blank strings
    %i[source_url serving_size].each do |field|
      @attributes[field] = nil if @attributes[field].blank?
    end

    @attributes.merge!(image_attributes) if image?

    @attributes
  end

  def image_attributes
    # e.g. "image/jpeg"
    mime_type = @params[:recipe][:image][:type]
    file = @params[:recipe][:image][:tempfile]
    pipeline = ImageProcessing::MiniMagick.source(file)

    # `resize_to_cover` will resize to ensure the image fits within the
    # dimensions, but will not apply any cropping to the excess/overflow
    regular = pipeline.resize_to_cover!(750, 300)
    thumb = pipeline.resize_to_cover!(100, 100)

    attrs = {
      image: image_to_raw(regular, mime_type),
      image_thumbnail: image_to_raw(thumb, mime_type)
    }

    # Tempfiles delete themselves, but regular `File` objects don't
    File.delete(regular)
    File.delete(thumb)

    attrs
  end

  def image?
    @params.dig(:recipe, :image, :tempfile).present?
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

  def image_to_raw(file, mime_type)
    "#{mime_type};base64,#{Base64.encode64(File.read(file))}"
  end
end
