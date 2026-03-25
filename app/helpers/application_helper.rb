module ApplicationHelper
  def dash_nav_class(path_pattern)
    current_path = request.path
    base_class = "flex items-center gap-3 w-full px-3 py-2.5 text-sm font-medium rounded-lg transition-colors"

    is_active = current_path.start_with?(path_pattern)

    if is_active
      "#{base_class} bg-gray-900 text-white"
    else
      "#{base_class} text-gray-600 hover:text-gray-900 hover:bg-gray-100"
    end
  end
end
