module MachineLearningHelper
  def script_select_options
    @scripts_info.map { |info| info[:name] }
  end
end
