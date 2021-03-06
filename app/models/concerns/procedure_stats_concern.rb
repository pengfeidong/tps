module ProcedureStatsConcern
  extend ActiveSupport::Concern

  def stats_usual_traitement_time
    Rails.cache.fetch("#{cache_key_with_version}/stats_usual_traitement_time", expires_in: 12.hours) do
      usual_traitement_time
    end
  end

  def stats_dossiers_funnel
    Rails.cache.fetch("#{cache_key_with_version}/stats_dossiers_funnel", expires_in: 12.hours) do
      [
        ['Démarrés', dossiers.count],
        ['Déposés', dossiers.state_not_brouillon.count],
        ['Instruction débutée', dossiers.state_instruction_commencee.count],
        ['Traités', dossiers.state_termine.count]
      ]
    end
  end

  def stats_termines_states
    Rails.cache.fetch("#{cache_key_with_version}/stats_termines_states", expires_in: 12.hours) do
      [
        ['Acceptés', dossiers.where(state: :accepte).count],
        ['Refusés', dossiers.where(state: :refuse).count],
        ['Classés sans suite', dossiers.where(state: :sans_suite).count]
      ]
    end
  end

  def stats_termines_by_week
    Rails.cache.fetch("#{cache_key_with_version}/stats_termines_by_week", expires_in: 12.hours) do
      now = Time.zone.now
      chart_data = dossiers.includes(:traitements)
        .state_termine
        .where(traitements: { processed_at: (now.beginning_of_week - 6.months)..now.end_of_week })

      dossier_state_values = chart_data.pluck(:state).sort.uniq

      # rubocop:disable Style/HashTransformValues
      dossier_state_values
        .map do |state|
          { name: state, data: chart_data.where(state: state).group_by_week { |dossier| dossier.traitements.first.processed_at }.map { |k, v| [k, v.count] }.to_h }
          # rubocop:enable Style/HashTransformValues
        end
    end
  end
end
