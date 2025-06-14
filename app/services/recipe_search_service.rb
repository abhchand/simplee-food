class RecipeSearchService
  DEFAULT_PAGE_SIZE = 10

  # params should be of the form:
  # {
  #   'page'      => (number)  # Optional. Defaults to `1`. Will be limited to valid bounds
  #   'page_size' => (number)  # Optional. Defaults to `DEFAULT_PAGE_SIZE`. Will
  #                            # be limited to positive numbers
  #   'search'    => (string)  # Optional. Ignored if blank.
  #   'sort_by'   => (string)  # Optional. Sorts by 'name ASC' if specified as "name",
  #                            # defaults to `updated_at DESC` otherwise.
  #   'tag'       => (string)  # Optional. The *slug* of the `Tag` to scope all searches by.
  # }
  def initialize(params = {})
    @params = params
  end

  def call
    @recipes = Recipe.all

    scope_to_tag!
    search!
    sort!

    @total = @recipes.count

    paginate!

    {
      'items' => @recipes,
      'first_item' => @first_item,
      'last_item' => @last_item,
      'total_items' => @total,
      'current_page' => page,
      'last_page' => max_page,
      'tag' => @tag
    }
  end

  private

  def max_page
    @max_page ||= (@total.to_f / page_size).ceil
  end

  def page
    @page ||=
      begin
        req_page = (@params['page'] || 1).to_i

        case
        when req_page <= 0 || max_page <= 0
          1
        when req_page > max_page
          max_page
        else
          req_page
        end
      end
  end

  def page_size
    @page_size ||=
      (
        if @params['page_size'].to_i <= 0
          DEFAULT_PAGE_SIZE
        else
          @params['page_size'].to_i
        end
      )
  end

  def paginate!
    # E.g. - Dataset is 7 records. Request is for Page 3, with Page Size of 2
    #
    #       P1    P2    P3    P4
    #      ----------------------
    # idx   0 1   2 3   4 5   6
    # num   1 2   3 4   5 6   7
    #
    #   * sql OFFSET will be page-1 * page_size = 2 * 2 = 4
    #   * sql LIMIT will be page_size = 2
    #   * first_item will be (page * page_size) + 1 = offset + 1 = 5
    #   * last_item will be first_item + page_size - 1 = 5 + 2 - 1 = 6
    #     * exception: if first or last num are > total, they will be trimmed
    #       to total
    #
    offset = (page - 1) * page_size
    limit = page_size
    @recipes = @recipes.offset(offset).limit(limit)

    @first_item = offset + 1
    @last_item = @first_item + page_size - 1

    # Trim if needed
    @first_item = @total if @first_item > @total
    @last_item = @total if @last_item > @total
  end

  def scope_to_tag!
    return if @params['tag'].blank?

    @tag = Tag.find_by_slug(@params['tag'])
    @recipes = @recipes.joins(:tags).where('tags.id = ?', @tag.id)
  end

  def search!
    return if @params['search'].nil? || @params['search'].length == 0

    @params['search']
      .split(' ')
      .each do |token|
        @recipes =
          @recipes.where("LOWER(recipes.name) LIKE '%#{token.downcase}%'")
      end
  end

  def sort!
    # Sort by `name` if explicitly specified. If not, sort by recently created
    # as a default.
    field, direction =
      if @params['sort_by']&.downcase == 'name'
        %w[recipes.name asc]
      else
        %w[recipes.updated_at desc]
      end

    @recipes = @recipes.order("#{field} #{direction}")
  end
end
