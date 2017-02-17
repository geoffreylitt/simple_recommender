module SimpleRecommender
  module Recommendable
    extend ActiveSupport::Concern
    DEFAULT_N_RESULTS = 10
    SIMILARITY_KEY = "similarity" # todo: allow renaming to avoid conflicts
    AssociationMetadata = Struct.new(:join_table, :foreign_key, :association_foreign_key)

    module ClassMethods
      def similar_by(association_name)
        define_method :similar_items do |n_results: DEFAULT_N_RESULTS|
          query = similar_query(
                    association_name: association_name,
                    n_results: n_results
                  )
          self.class.find_by_sql(query)
        end
      end
    end

    included do
      private

      # Returns database metadata about an association based on its type,
      # used in constructing a similarity query based on that association
      def association_metadata(reflection)
        case reflection
        when ActiveRecord::Reflection::HasAndBelongsToManyReflection
          AssociationMetadata.new(
            reflection.join_table,
            reflection.foreign_key,
            reflection.association_foreign_key
          )
        when ActiveRecord::Reflection::ThroughReflection
          AssociationMetadata.new(
            reflection.through_reflection.table_name,
            reflection.through_reflection.foreign_key,
            reflection.association_foreign_key
          )
        else
          raise ArgumentError, "Association '#{reflection.name}' is not a supported type"
        end
      end

      # Returns a Postgres query that can be executed to return similar items.
      # Reflects on the association to get relevant table names, and then
      # uses Postgres's integer array intersection/union operators to
      # efficiently compute a Jaccard similarity metric between this item
      # and all other items in the table.
      def similar_query(association_name:, n_results:)
        reflection = self.class.reflect_on_association(association_name)

        if reflection.nil?
          raise ArgumentError, "Could not find association #{association_name}"
        end

        metadata = association_metadata(reflection)
        join_table = metadata[:join_table]
        fkey = metadata[:foreign_key]
        assoc_fkey = metadata[:association_foreign_key]
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
