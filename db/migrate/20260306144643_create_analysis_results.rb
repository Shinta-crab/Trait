class CreateAnalysisResults < ActiveRecord::Migration[7.2]
  def change
    create_table :analysis_results do |t|
      t.references :user, null: false, foreign_key: true
      t.datetime :analyzed_at, default: -> { 'CURRENT_TIMESTAMP' }
      t.timestamps
    end
  end
end
