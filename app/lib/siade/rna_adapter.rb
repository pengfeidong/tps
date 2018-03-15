class SIADE::RNAAdapter
  def initialize(siret, procedure_id)
    @siret = siret
    @procedure_id = procedure_id
  end

  def data_source
    @data_source ||= SIADE::API.rna(@siret, @procedure_id)
  end

  def to_params
    if data_source[:association][:id].nil?
      return nil
    end
    params = data_source[:association].slice(*attr_to_fetch)
    params[:rna] = data_source[:association][:id]
    params
  rescue
    nil
  end

  private

  def attr_to_fetch
    [
      :titre,
      :objet,
      :date_creation,
      :date_declaration,
      :date_publication
    ]
  end
end
