class Source
  @@kinds = { recipe: '献立', ingredients: '材料'}
  @@recipe_kinds = {
    japanese: '和食',
    western: '洋食',
    chinese: '中華',
    french: 'フレンチ',
    italian: 'イタリアン',
    spanish: 'スパニッシュ',
    asian: 'アジアン',
    ethnic: 'エスニック',
    dessert: 'デザート'
  }

  DEFAULT_FLAGS = {
    is_ingridients: false,
    is_recipe: false,
    is_recipe_kind: false
  }

  attr_accessor :ingredients, :recipe_kind, :recipes, :text

  def initialize(text, flags=DEFAULT_FLAGS)
    @text = text
    @flags = flags
    evaluate
  end

  def self.kinds
    @@kinds
  end

  def self.recipe_kinds
    @@recipe_kinds
  end

  def ingredients?
    @flags[:is_ingredients] || text_matches_to_ingredients_wordings?
  end

  def recipe?
    @flags[:is_recipe]
  end

  def recipe_kind?
    @flags[:is_recipe_kind]
  end

private
  def evaluate
    case
    when recipe?
      @recipes = Recipe.contains(name: @text)
    when ingredients?
      @ingredients = get_ingredients
    when recipe_kind?
      @recipe_kind = get_recipe_kind
    end
  end

  def get_recipe_kind
    @@recipe_kinds.each do |_, recipe_kind|
      return RecipeKind.find_by(name: recipe_kind) if text_contains(recipe_kind)
    end
    false
  end

  def get_ingredients
    ingredients = if @text.match(/、/)
      @text.split(/、/)
    elsif @text.match(/\n/)
      @text.split(/\n/)
    else
      [@text]
    end

    ingredients.map! { |ingredient| ingredient.gsub(/を使った.+\z|を使用した.+\z/, '') }

    ids = ingredients.map do |ingredient|
      Ingredient.find_by(hiragana: ingredient.to_hiragana).try(:id)
    end.flatten

    Ingredient.where(id: ids)
  end

  def text_matches_to_ingredients_wordings?
    @text.match? (/を使った料理|を使ったレシピ|を使用した料理|を使用したレシピ/)
  end

  def text_contains(string)
    Regexp.new(string).match(@text)
  end
end
