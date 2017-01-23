module SimpleRecommender
  module Recommendable
    extend ActiveSupport::Concern

    included do
      SIMILARITY_KEY = "similarity" # todo: allow renaming to avoid conflicts
      DEFAULT_N_RESULTS = 10

      def similar_by(association_name, n_results: DEFAULT_N_RESULTS)
        self.class.find_by_sql(similar_query(
          association_name: association_name,
          n_results: n_results
        ))
      end

      # For each HABTM association, add a dynamically named shortcut method
      # e.g. when basing similarity on users, define :similar_by_users
      # todo: should be able to support has_many and has_many_through
      #       in addition to HABTM
      self.reflect_on_all_associations(:has_and_belongs_to_many).each do |association|
        association_name = association.name

        define_method "similar_by_#{association_name}" do |n_results: DEFAULT_N_RESULTS|
          similar_by(association_name, n_results: n_results)
        end
      end

      private

      def similar_query(association_name:, n_results:)
        association = self.class.reflect_on_association(association_name)
        join_table = association.join_table #books_users
        fkey = association.foreign_key #book_id
        assoc_fkey = association.association_foreign_key #user_id
        this_table = self.class.table_name

        <<-SQL
          WITH similar_items AS (
            SELECT
              t2.#{fkey},
              (# (array_agg(DISTINCT t1.#{assoc_fkey}) & array_agg(DISTINCT t2.#{assoc_fkey})))::float/
              (# (array_agg(DISTINCT t1.#{assoc_fkey}) | array_agg(DISTINCT t2.#{assoc_fkey})))::float as similarity
            FROM #{join_table} AS t1, #{join_table} AS t2
            WHERE t1.#{fkey} = #{id} and t2.#{fkey} != #{id}
            GROUP BY t2.#{fkey}
            ORDER BY similarity DESC
            LIMIT #{n_results}
          )
          SELECT #{this_table}.*, similarity
          FROM similar_items
          JOIN #{this_table} ON #{this_table}.id = similar_items.#{fkey}
          ORDER BY similarity DESC;
        SQL
      end
    end
  end
end
