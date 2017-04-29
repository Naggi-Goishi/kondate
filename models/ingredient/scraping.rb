require 'active_support/concern'

class Ingredient < ActiveRecord::Base
  module Scraping
    extend ActiveSupport::Concern
    AGENT = Mechanize.new

    class_methods do
      def import
        Recipe.all.each do |recipe|
          save_ingredients(recipe)
        end
      end

      private
        def save_ingredients(recipe)
          page = AGENT.get(recipe.url)
          rows = page.search('.table_recipes tbody tr')
          rows[1..rows.length].map do |row|
            next if (row.children.length == 3)

            name = clean(row.children[1].inner_text.strip)
            next if name.nil? || name.empty?
            ingredient = Ingredient.where(name: name).first_or_initialize
            ingredient.recipes << recipe
            ingredient.save
          end
        end

        def clean(string)
          string = string.gsub(/（.+）|\(.+\)|\(.+）|（.+\)|\(.+\z|.+\.|（.+$|^[ABCDEFG]|\d{1}.+\z|[[:space:]]|├|└|■|下記３種のソースを混ぜる/, '')
          string = string.gsub(/.\(.+\z/, '') + string.match(/.\(.+\z/)[0][0] if string.match(/.\(.+\z/)
          string
        end
    end
  end
end